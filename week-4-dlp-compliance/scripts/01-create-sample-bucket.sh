#!/usr/bin/env bash
# Creates a private, encrypted, tagged bucket and uploads SYNTHETIC sensitive data
# for Macie to find. No real personal data is used.
source "$(dirname "$0")/00-env.sh"
DATA_DIR="$(dirname "$0")/../sample-data"

aws s3api create-bucket --bucket "$BUCKET" \
  --create-bucket-configuration LocationConstraint="$AWS_REGION"
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
# SSE-S3 keeps cost at zero (no KMS key charges) for this short lab.
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-bucket-tagging --bucket "$BUCKET" \
  --tagging 'TagSet=[{Key=DataClassification,Value=restricted},{Key=Owner,Value=dp-lab},{Key=Environment,Value=lab}]'
aws s3 cp "$DATA_DIR/" "s3://$BUCKET/" --recursive
aws s3 ls "s3://$BUCKET/" | tee "$OUT_DIR/01-bucket-objects.txt"
