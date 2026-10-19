# Evidence notes

- `04-restricted-console-denied.png`: the Console returns "Insufficient permissions to list objects" for the restricted bucket. This is expected: the bucket policy denies every principal except the named admin, the `dp-lab-restricted-reader` role and the Access Analyzer service-linked role.
- `03-restricted-policy.png`: the Console also blocks the Permissions tab on the restricted bucket, so this screenshot shows the policy source file `policies/bucket-policy-restricted.json` (placeholders are filled in by `scripts/02-apply-policies.sh`).
- To read the applied policy, use the CLI as `lab-admin`:
  `aws s3api get-bucket-policy --bucket dp-lab-restricted-<ACCOUNT_ID> --query Policy --output text`
