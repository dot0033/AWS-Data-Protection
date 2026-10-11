#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION="${AWS_REGION:-eu-central-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ADMIN_ARN="${ADMIN_ARN:-$(aws sts get-caller-identity --query Arn --output text)}"
ALLOWED_ROLE_ARN="${ALLOWED_ROLE_ARN:-arn:aws:iam::$ACCOUNT_ID:role/dp-lab-restricted-reader}"
DIR="$(cd "$(dirname "$0")/.." && pwd)/policies"
TMP="$(mktemp -d)"

# Deny insecure transport on internal + confidential
for L in internal confidential; do
  B="dp-lab-$L-$ACCOUNT_ID"
  sed "s|BUCKET|$B|g" "$DIR/bucket-policy-deny-insecure.json" > "$TMP/$L.json"
  aws s3api put-bucket-policy --bucket "$B" --policy "file://$TMP/$L.json"
  echo "Applied deny-insecure policy to $B"
done

# Restricted policy (named principals only)
B="dp-lab-restricted-$ACCOUNT_ID"
sed -e "s|BUCKET|$B|g" -e "s|ADMIN_ARN|$ADMIN_ARN|g" \
    -e "s|ALLOWED_ROLE_ARN|$ALLOWED_ROLE_ARN|g" \
    "$DIR/bucket-policy-restricted.json" > "$TMP/restricted.json"
aws s3api put-bucket-policy --bucket "$B" --policy "file://$TMP/restricted.json"
echo "Applied restricted policy to $B (admin: $ADMIN_ARN)"

# Lifecycle on internal bucket
aws s3api put-bucket-lifecycle-configuration \
  --bucket "dp-lab-internal-$ACCOUNT_ID" \
  --lifecycle-configuration "file://$DIR/lifecycle-policy.json"
echo "Applied lifecycle policy to internal bucket"

# Access Point on internal bucket
aws s3control create-access-point --account-id "$ACCOUNT_ID" \
  --name analytics-ap --bucket "dp-lab-internal-$ACCOUNT_ID" || \
  echo "Access point already exists"

rm -rf "$TMP"
