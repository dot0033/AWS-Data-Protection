#!/usr/bin/env bash
# Shared settings for the Week 4 lab. Source this file from the other scripts.
set -euo pipefail
export AWS_REGION="${AWS_REGION:-eu-central-1}"
export AWS_DEFAULT_REGION="$AWS_REGION"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export ACCOUNT_ID
export BUCKET="dp-lab-w4-sample-${ACCOUNT_ID}"
export JOB_NAME="dp-lab-w4-macie-job"
export OUT_DIR="${OUT_DIR:-$HOME/w4-evidence}"
mkdir -p "$OUT_DIR"
