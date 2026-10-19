#!/usr/bin/env bash
set -uo pipefail

export AWS_REGION="${AWS_REGION:-eu-central-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws s3control delete-access-point --account-id "$ACCOUNT_ID" --name analytics-ap
aws accessanalyzer delete-analyzer --analyzer-name dp-lab-analyzer

for L in internal confidential restricted; do
  B="dp-lab-$L-$ACCOUNT_ID"
  echo "Emptying $B ..."
  for TYPE in Versions DeleteMarkers; do
    aws s3api list-object-versions --bucket "$B" \
      --query "${TYPE}[].[Key,VersionId]" --output text | \
    while read -r KEY VID; do
      [ -z "$KEY" ] || [ "$KEY" = "None" ] && continue
      aws s3api delete-object --bucket "$B" --key "$KEY" --version-id "$VID" > /dev/null
    done
  done
  aws s3api delete-bucket --bucket "$B"
  echo "Deleted $B"
done
