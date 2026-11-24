#!/usr/bin/env bash
# Free detection evidence: CloudTrail event history (90 days, no trail needed)
# shows who changed the sample bucket's security settings.
source "$(dirname "$0")/00-env.sh"
for ev in CreateBucket PutBucketPublicAccessBlock PutBucketEncryption PutBucketTagging; do
  aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=$ev \
    --max-results 5 --query "Events[?contains(Resources[].ResourceName | join(',', @), '$BUCKET')].[EventTime,EventName,Username]" \
    --output text
done | sed "s/$ACCOUNT_ID/<ACCOUNT_ID>/g" | tee "$OUT_DIR/07-cloudtrail-events.txt"
