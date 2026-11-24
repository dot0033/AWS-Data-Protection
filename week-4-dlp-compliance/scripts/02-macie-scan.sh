#!/usr/bin/env bash
# Enables Macie (30-day free trial on first use) and runs ONE one-time
# sensitive data discovery job on the sample bucket only.
source "$(dirname "$0")/00-env.sh"

aws macie2 enable-macie || true
if ! aws macie2 get-macie-session >/dev/null; then echo "Macie is not available on this account (see docs/01-macie-findings-report.md)"; exit 1; fi
# Turn off account-wide automated discovery so only the sample bucket is scanned.
aws macie2 update-automated-discovery-configuration --status DISABLED 2>/dev/null || true

JOB_ID="$(aws macie2 create-classification-job \
  --job-type ONE_TIME --name "$JOB_NAME-$(date +%s)" \
  --s3-job-definition "{\"bucketDefinitions\":[{\"accountId\":\"$ACCOUNT_ID\",\"buckets\":[\"$BUCKET\"]}]}" \
  --query jobId --output text)"
echo "$JOB_ID" > "$OUT_DIR/macie-job-id.txt"
echo "Job $JOB_ID started. Waiting for it to finish (usually 5-20 minutes)..."
while true; do
  STATUS="$(aws macie2 describe-classification-job --job-id "$JOB_ID" --query jobStatus --output text)"
  echo "$(date +%T) $STATUS"
  [ "$STATUS" = "COMPLETE" ] && break
  [ "$STATUS" = "CANCELLED" ] && exit 1
  sleep 30
done
sleep 60  # findings can appear shortly after the job completes
bash "$(dirname "$0")/04-export-findings.sh" macie
