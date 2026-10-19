#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION="${AWS_REGION:-eu-central-1}"
EVID="$(cd "$(dirname "$0")/.." && pwd)/evidence"

ARN=$(aws accessanalyzer create-analyzer --analyzer-name dp-lab-analyzer \
  --type ACCOUNT --query arn --output text 2>/dev/null || \
  aws accessanalyzer get-analyzer --analyzer-name dp-lab-analyzer \
  --query analyzer.arn --output text)

echo "Analyzer: $ARN"
aws accessanalyzer list-findings --analyzer-arn "$ARN" > "$EVID/access-analyzer-findings.json"
echo "Saved findings to evidence/access-analyzer-findings.json"
