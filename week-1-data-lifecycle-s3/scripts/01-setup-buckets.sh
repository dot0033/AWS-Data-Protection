#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION="${AWS_REGION:-eu-central-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Enabling account-level Block Public Access..."
aws s3control put-public-access-block --account-id "$ACCOUNT_ID" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

for L in internal confidential restricted; do
  B="dp-lab-$L-$ACCOUNT_ID"
  echo "Creating $B ..."
  aws s3api create-bucket --bucket "$B" --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
  aws s3api put-bucket-versioning --bucket "$B" \
    --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption --bucket "$B" \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
  aws s3api put-bucket-tagging --bucket "$B" \
    --tagging "TagSet=[{Key=DataClassification,Value=$L},{Key=Owner,Value=security-team},{Key=Environment,Value=lab}]"
done
echo "Done."
