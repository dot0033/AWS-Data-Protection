#!/usr/bin/env bash
# Enables GuardDuty (30-day free trial) with S3 Protection and generates
# SAMPLE findings for S3 data threats. Sample findings are clearly marked
# "[SAMPLE]" by AWS and do not mean a real attack happened.
source "$(dirname "$0")/00-env.sh"

aws guardduty list-detectors >/dev/null || { echo "GuardDuty is not available on this account"; exit 1; }
DET="$(aws guardduty list-detectors --query 'DetectorIds[0]' --output text)"
if [ "$DET" = "None" ] || [ -z "$DET" ]; then
  DET="$(aws guardduty create-detector --enable \
    --features '[{"Name":"S3_DATA_EVENTS","Status":"ENABLED"}]' \
    --query DetectorId --output text)"
fi
echo "$DET" > "$OUT_DIR/guardduty-detector-id.txt"
aws guardduty create-sample-findings --detector-id "$DET" --finding-types \
  "Exfiltration:S3/AnomalousBehavior" \
  "Policy:S3/BucketBlockPublicAccessDisabled" \
  "UnauthorizedAccess:S3/TorIPCaller" \
  "Discovery:S3/AnomalousBehavior"
sleep 20
bash "$(dirname "$0")/04-export-findings.sh" guardduty
