#!/usr/bin/env bash
# Removes everything the Week 4 lab created so nothing keeps costing money.
source "$(dirname "$0")/00-env.sh"
set +e
aws s3 rm "s3://$BUCKET" --recursive
aws s3api delete-bucket --bucket "$BUCKET"
aws macie2 disable-macie && echo "Macie disabled (findings and jobs deleted)"
for DET in $(aws guardduty list-detectors --query 'DetectorIds' --output text); do
  aws guardduty delete-detector --detector-id "$DET" && echo "GuardDuty detector $DET deleted"
done
echo "--- after cleanup ---"
aws s3api head-bucket --bucket "$BUCKET" 2>&1 | head -1
aws macie2 get-macie-session 2>&1 | head -1
aws guardduty list-detectors --output text
