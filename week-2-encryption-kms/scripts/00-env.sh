#!/usr/bin/env bash
# Shared settings for Week 2 scripts. Source it: . ./00-env.sh
set -euo pipefail
export AWS_REGION="${AWS_REGION:-eu-central-1}"
export AWS_DEFAULT_REGION="$AWS_REGION"
export AWS_PAGER=""
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POL="$HERE/../policies"
EVD="$HERE/../evidence"
mkdir -p "$EVD"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ADMIN_ARN=$(aws sts get-caller-identity --query Arn --output text)   # run as IAM user lab-admin
CONF_BUCKET="dp-lab-confidential-$ACCOUNT_ID"
REST_BUCKET="dp-lab-restricted-$ACCOUNT_ID"
READER_ROLE="dp-lab-restricted-reader"
READER_ARN="arn:aws:iam::$ACCOUNT_ID:role/$READER_ROLE"
CONF_ALIAS="alias/dp-lab-confidential"
REST_ALIAS="alias/dp-lab-restricted"
TMP="$(mktemp -d)"
# aws.exe on Windows Git Bash cannot read /tmp paths; convert when cygpath exists
p() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else echo "$1"; fi; }
# Fill a policy template; extra args are KEY=VALUE pairs
render() { local src="$1"; shift; local out="$TMP/$(basename "$src")"
  sed -e "s#ACCOUNT_ID#$ACCOUNT_ID#g" -e "s#ADMIN_ARN#$ADMIN_ARN#g" -e "s#READER_ARN#$READER_ARN#g" "$src" > "$out"
  for kv in "$@"; do sed -i "s#${kv%%=*}#${kv#*=}#g" "$out"; done
  p "$out"; }
# Save evidence with the account ID redacted
save() { sed -e "s/$ACCOUNT_ID/<ACCOUNT_ID>/g" > "$EVD/$1"; echo "  evidence -> $1"; }
key_arn() { aws kms describe-key --key-id "$1" --query KeyMetadata.Arn --output text; }
