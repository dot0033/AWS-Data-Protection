#!/usr/bin/env bash
set -uo pipefail

export AWS_REGION="${AWS_REGION:-eu-central-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
B="dp-lab-confidential-$ACCOUNT_ID"
I="dp-lab-internal-$ACCOUNT_ID"
TMP="$(mktemp -d)"
winpath() { cygpath -m "$1" 2>/dev/null || echo "$1"; }

echo "== 1. Upload a test file and check encryption =="
echo "test" > "$TMP/test.txt"
aws s3api put-object --bucket "$I" --key test.txt --body "$(winpath "$TMP/test.txt")"
aws s3api head-object --bucket "$I" --key test.txt \
  --query '{Encryption:ServerSideEncryption,Version:VersionId}'

echo "== 2. HTTP access must be denied =="
aws s3api head-bucket --bucket "$B" \
  --endpoint-url "http://s3.$AWS_REGION.amazonaws.com" || echo "(denied as expected)"

echo "== 3. Public bucket policy must be rejected =="
cat > "$TMP/public-policy.json" << POLICY
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":"*",
"Action":"s3:GetObject","Resource":"arn:aws:s3:::$I/*"}]}
POLICY
aws s3api put-bucket-policy --bucket "$I" --policy "file://$(winpath "$TMP/public-policy.json")" \
  || echo "(rejected by Block Public Access as expected)"

echo "== 4. Bucket settings =="
for L in internal confidential restricted; do
  echo "--- $L ---"
  aws s3api get-bucket-tagging --bucket "dp-lab-$L-$ACCOUNT_ID"
  aws s3api get-bucket-versioning --bucket "dp-lab-$L-$ACCOUNT_ID"
done

rm -rf "$TMP"
