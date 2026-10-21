#!/usr/bin/env bash
# Creates the restricted reader role and the two customer managed KMS keys.
. "$(dirname "$0")/00-env.sh"

echo "1) Role $READER_ROLE"
if ! aws iam get-role --role-name "$READER_ROLE" >/dev/null 2>&1; then
  aws iam create-role --role-name "$READER_ROLE" \
    --assume-role-policy-document "file://$(render "$POL/restricted-reader-trust.json")" \
    --tags Key=Owner,Value=security-team Key=Environment,Value=lab >/dev/null
  sleep 10   # IAM propagation before KMS validates the principal
fi

mk_key() { # alias policy-file description classification
  if aws kms describe-key --key-id "$1" >/dev/null 2>&1; then key_arn "$1"; return; fi
  local arn
  arn=$(aws kms create-key --description "$3" --key-usage ENCRYPT_DECRYPT --key-spec SYMMETRIC_DEFAULT \
        --policy "file://$(render "$2")" \
        --tags TagKey=Owner,TagValue=security-team TagKey=Environment,TagValue=lab TagKey=DataClassification,TagValue="$4" \
        --query KeyMetadata.Arn --output text)
  aws kms create-alias --alias-name "$1" --target-key-id "$arn"
  echo "$arn"; }

echo "2) KMS keys"
CONF_KEY=$(mk_key "$CONF_ALIAS" "$POL/kms-key-policy-confidential.json" "dp-lab confidential data (S3, DynamoDB, EBS, RDS)" confidential)
REST_KEY=$(mk_key "$REST_ALIAS" "$POL/kms-key-policy-restricted.json" "dp-lab restricted data (S3 restricted bucket only)" restricted)
echo "   confidential: $CONF_KEY"; echo "   restricted:   $REST_KEY"

echo "3) Reader role permissions (needs the restricted key ARN)"
aws iam put-role-policy --role-name "$READER_ROLE" --policy-name read-restricted \
  --policy-document "file://$(render "$POL/restricted-reader-policy.json" RESTRICTED_BUCKET="$REST_BUCKET" RESTRICTED_KEY_ARN="$REST_KEY")"

echo "4) Rotation: confidential 365 days, restricted 90 days"
aws kms enable-key-rotation --key-id "$CONF_KEY" --rotation-period-in-days 365
aws kms enable-key-rotation --key-id "$REST_KEY" --rotation-period-in-days 90
echo "Done."
