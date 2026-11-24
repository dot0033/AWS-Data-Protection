#!/usr/bin/env bash
# Exports findings to JSON and prints a short summary. Account IDs are
# replaced with <ACCOUNT_ID> so the files can be committed safely.
source "$(dirname "$0")/00-env.sh"
redact() { sed "s/$ACCOUNT_ID/<ACCOUNT_ID>/g"; }
what="${1:-all}"

if [ "$what" = "macie" ] || [ "$what" = "all" ]; then
  IDS="$(aws macie2 list-findings --query 'findingIds' --output text)"
  if [ -n "$IDS" ] && [ "$IDS" != "None" ]; then
    aws macie2 get-findings --finding-ids $IDS | redact > "$OUT_DIR/macie-findings.json"
    aws macie2 get-findings --finding-ids $IDS --query 'findings[].[severity.description,type,resourcesAffected.s3Object.key,classificationDetails.result.sensitiveData[].detections[].[type,count]]' --output json | redact | tee "$OUT_DIR/macie-findings-summary.json"
  else
    echo "No Macie findings yet" | tee "$OUT_DIR/macie-findings-summary.json"
  fi
  aws macie2 describe-classification-job --job-id "$(cat "$OUT_DIR/macie-job-id.txt")" \
    --query '{name:name,status:jobStatus,type:jobType,created:createdAt,stats:statistics}' | redact > "$OUT_DIR/macie-job.json"
fi

if [ "$what" = "guardduty" ] || [ "$what" = "all" ]; then
  DET="$(cat "$OUT_DIR/guardduty-detector-id.txt")"
  IDS="$(aws guardduty list-findings --detector-id "$DET" --query 'FindingIds' --output text)"
  aws guardduty get-findings --detector-id "$DET" --finding-ids $IDS | redact > "$OUT_DIR/guardduty-findings.json"
  aws guardduty get-findings --detector-id "$DET" --finding-ids $IDS \
    --query 'Findings[].[Severity,Type,Title]' --output table | redact | tee "$OUT_DIR/guardduty-findings-summary.txt"
  aws guardduty get-detector --detector-id "$DET" --query '{status:Status,features:Features[].[Name,Status]}' | redact > "$OUT_DIR/guardduty-detector.json"
fi
