#!/usr/bin/env bash
# Creates (or upgrades) the confidential and restricted buckets with SSE-KMS + S3 Bucket Keys.
. "$(dirname "$0")/00-env.sh"
CONF_KEY=$(key_arn "$CONF_ALIAS"); REST_KEY=$(key_arn "$REST_ALIAS")

aws s3control put-public-access-block --account-id "$ACCOUNT_ID" --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

setup() { # bucket level key policy-file
  local B=$1 L=$2 K=$3
  if ! aws s3api head-bucket --bucket "$B" 2>/dev/null; then
    aws s3api create-bucket --bucket "$B" --create-bucket-configuration LocationConstraint="$AWS_REGION" >/dev/null
  fi
  aws s3api put-bucket-versioning --bucket "$B" --versioning-configuration Status=Enabled
  aws s3api put-bucket-tagging --bucket "$B" \
    --tagging "TagSet=[{Key=DataClassification,Value=$L},{Key=Owner,Value=security-team},{Key=Environment,Value=lab}]"
  aws s3api put-bucket-encryption --bucket "$B" --server-side-encryption-configuration \
    "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"aws:kms\",\"KMSMasterKeyID\":\"$K\"},\"BucketKeyEnabled\":true}]}"
  aws s3api put-bucket-policy --bucket "$B" --policy "file://$(render "$4" BUCKET="$B" KEY_ARN="$K")"
  echo "  $B -> SSE-KMS ($L key)"; }

setup "$CONF_BUCKET" confidential "$CONF_KEY" "$POL/bucket-policy-confidential-kms.json"
setup "$REST_BUCKET" restricted   "$REST_KEY" "$POL/bucket-policy-restricted-kms.json"

echo "Test objects"
echo "sample confidential record (fake data)" > "$TMP/conf.txt"
echo "sample restricted record (fake data)"   > "$TMP/rest.txt"
echo "archived confidential record (fake data)" > "$TMP/archive.txt"
aws s3api put-object --bucket "$CONF_BUCKET" --key test/conf.txt --body "$(p "$TMP/conf.txt")" >/dev/null
aws s3api put-object --bucket "$REST_BUCKET" --key test/rest.txt --body "$(p "$TMP/rest.txt")" >/dev/null
# Glacier tier: S3 Glacier Instant Retrieval object, encrypted with the confidential key
aws s3api put-object --bucket "$CONF_BUCKET" --key archive/archive.txt --body "$(p "$TMP/archive.txt")" \
  --storage-class GLACIER_IR --server-side-encryption aws:kms --ssekms-key-id "$CONF_KEY" >/dev/null
echo "Done."
