#!/usr/bin/env bash
# KMS hands-on: direct encrypt/decrypt, envelope encryption, grants, on-demand rotation.
. "$(dirname "$0")/00-env.sh"
CONF_KEY=$(key_arn "$CONF_ALIAS"); REST_KEY=$(key_arn "$REST_ALIAS")
LOG="$TMP/kms-lab.txt"; : > "$LOG"
log() { echo "$*" | tee -a "$LOG"; }

log "== 1. Direct encrypt/decrypt (max 4 KB) with $CONF_ALIAS"
printf 'hello kms' > "$TMP/plain.txt"
aws kms encrypt --key-id "$CONF_ALIAS" --plaintext "fileb://$(p "$TMP/plain.txt")" \
  --query CiphertextBlob --output text | base64 -d > "$TMP/cipher.bin"
OUT=$(aws kms decrypt --ciphertext-blob "fileb://$(p "$TMP/cipher.bin")" --query Plaintext --output text | base64 -d)
log "ciphertext bytes: $(wc -c < "$TMP/cipher.bin"), decrypted: '$OUT' (key id is read from the ciphertext)"

log "== 2. Envelope encryption: data key from KMS, data encrypted locally"
aws kms generate-data-key --key-id "$CONF_ALIAS" --key-spec AES_256 --output json > "$TMP/dk.json"
python3 - "$TMP/dk.json" "$TMP/edk.bin" <<'PY'
import json,base64,sys
d=json.load(open(sys.argv[1])); open(sys.argv[2],'wb').write(base64.b64decode(d['CiphertextBlob']))
PY
rm -f "$TMP/dk.json"   # plaintext data key discarded, only the encrypted data key is kept
log "encrypted data key stored ($(wc -c < "$TMP/edk.bin") bytes); plaintext data key discarded"
aws kms decrypt --ciphertext-blob "fileb://$(p "$TMP/edk.bin")" --query KeyId --output text | sed 's/^/data key unwrapped by: /' | tee -a "$LOG"

log "== 3. Restricted key: direct use by the key admin outside S3 is blocked by the key policy"
if aws kms generate-data-key --key-id "$REST_KEY" --key-spec AES_256 >/dev/null 2>"$TMP/err.txt"; then log "UNEXPECTED: allowed"; else log "denied as expected: $(grep -o 'AccessDeniedException' "$TMP/err.txt" | head -1)"; fi

log "== 4. Grant: temporary GenerateDataKey/Decrypt for $READER_ROLE on the restricted key"
read -r GRANT GTOKEN < <(aws kms create-grant --key-id "$REST_KEY" --grantee-principal "$READER_ARN" \
  --operations GenerateDataKey Decrypt --name dp-lab-temp-reader-grant --query '[GrantId,GrantToken]' --output text)
aws kms list-grants --key-id "$REST_KEY" --query 'Grants[].{Name:Name,Grantee:GranteePrincipal,Ops:Operations}' --output json | tee -a "$LOG"
if [[ "$ADMIN_ARN" == *":root" ]]; then
  # The root user cannot call sts:AssumeRole, so the reader is tested with the IAM policy simulator instead
  log "caller is the account root user: reader role cannot be assumed, using IAM policy simulator"
  for R in "arn:aws:s3:::$REST_BUCKET/test/rest.txt" "arn:aws:s3:::$CONF_BUCKET/test/conf.txt"; do
    log "simulate s3:GetObject on $R: $(aws iam simulate-principal-policy --policy-source-arn "$READER_ARN" \
      --action-names s3:GetObject --resource-arns "$R" --query 'EvaluationResults[0].EvalDecision' --output text)"
  done
  aws kms revoke-grant --key-id "$REST_KEY" --grant-id "$GRANT"
  log "grant revoked; remaining grants: $(aws kms list-grants --key-id "$REST_KEY" --query 'length(Grants)')"
else
CREDS=$(aws sts assume-role --role-arn "$READER_ARN" --role-session-name kms-lab --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text)
as_reader() { read -r AK SK ST <<< "$CREDS"; AWS_ACCESS_KEY_ID=$AK AWS_SECRET_ACCESS_KEY=$SK AWS_SESSION_TOKEN=$ST "$@"; }
if as_reader aws kms generate-data-key --key-id "$REST_KEY" --key-spec AES_256 --grant-tokens "$GTOKEN" >/dev/null 2>"$TMP/err.txt"
then log "reader with grant: GenerateDataKey ALLOWED"; else log "reader with grant: denied ($(head -c 200 "$TMP/err.txt"))"; fi
aws kms revoke-grant --key-id "$REST_KEY" --grant-id "$GRANT"
sleep 10
if as_reader aws kms generate-data-key --key-id "$REST_KEY" --key-spec AES_256 >/dev/null 2>&1; then log "after revoke: UNEXPECTED allowed"; else log "after revoke: GenerateDataKey DENIED"; fi

log "== 5. Restricted reader through S3"
as_reader aws s3 cp "s3://$REST_BUCKET/test/rest.txt" - 2>&1 | sed 's/^/read restricted object: /' | tee -a "$LOG"
if as_reader aws s3 cp "s3://$CONF_BUCKET/test/conf.txt" - >/dev/null 2>&1; then log "read confidential object: UNEXPECTED allowed"; else log "read confidential object: DENIED (need-to-know)"; fi

fi

log "== 6. On-demand rotation of the restricted key"
aws kms rotate-key-on-demand --key-id "$REST_KEY" >/dev/null && log "rotation started"
save kms-lab-output.txt < "$LOG"
