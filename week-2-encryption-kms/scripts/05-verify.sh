#!/usr/bin/env bash
# Collects evidence for all Week 2 controls into ../evidence (account ID redacted).
. "$(dirname "$0")/00-env.sh"
CONF_KEY=$(key_arn "$CONF_ALIAS"); REST_KEY=$(key_arn "$REST_ALIAS")

for a in confidential restricted; do K=$(key_arn "alias/dp-lab-$a")
  aws kms describe-key --key-id "$K" --query 'KeyMetadata.{KeyId:KeyId,Arn:Arn,State:KeyState,Manager:KeyManager,Spec:KeySpec,Usage:KeyUsage,Origin:Origin,Description:Description}' --output json | save "kms-key-$a.json"
  aws kms get-key-policy --key-id "$K" --policy-name default --query Policy --output text | python3 -m json.tool | save "kms-key-policy-$a-applied.json"
  { aws kms get-key-rotation-status --key-id "$K" --output json; aws kms list-key-rotations --key-id "$K" --output json; } | save "kms-rotation-$a.json"
done
aws kms list-aliases --query "Aliases[?starts_with(AliasName,'alias/dp-lab')]" --output json | save kms-aliases.json

for B in "$CONF_BUCKET" "$REST_BUCKET"; do L=$(echo "$B" | cut -d- -f3)
  { echo "## bucket encryption"; aws s3api get-bucket-encryption --bucket "$B" --output json
    echo "## objects"; for k in $(aws s3api list-objects-v2 --bucket "$B" --query 'Contents[].Key' --output text); do
      echo "# $k"; aws s3api head-object --bucket "$B" --key "$k" --query '{SSE:ServerSideEncryption,KMSKey:SSEKMSKeyId,BucketKey:BucketKeyEnabled,StorageClass:StorageClass}' --output json; done; } | save "s3-$L-encryption.txt"
done
# Policy enforcement test: upload with SSE-S3 header must be denied
echo x > "$TMP/x.txt"
if aws s3api put-object --bucket "$REST_BUCKET" --key test/sse-s3.txt --body "$(p "$TMP/x.txt")" --server-side-encryption AES256 >/dev/null 2>&1
then echo "UNEXPECTED: SSE-S3 upload allowed"; else echo "SSE-S3 upload to restricted bucket: DENIED by bucket policy"; fi | save s3-policy-enforcement.txt

aws dynamodb describe-table --table-name dp-lab-confidential --query 'Table.{Table:TableName,SSE:SSEDescription}' --output json | save dynamodb-encryption.json
aws ec2 describe-volumes --filters Name=tag:Name,Values=dp-lab-ebs --query 'Volumes[].{Id:VolumeId,Encrypted:Encrypted,KmsKeyId:KmsKeyId,Size:Size,State:State}' --output json | save ebs-encryption.json
aws rds describe-db-instances --db-instance-identifier dp-lab-rds --query 'DBInstances[].{Id:DBInstanceIdentifier,Engine:Engine,Class:DBInstanceClass,StorageEncrypted:StorageEncrypted,KmsKeyId:KmsKeyId,Public:PubliclyAccessible}' --output json | save rds-encryption.json
aws ec2 get-ebs-encryption-by-default --output json | save ebs-encryption-by-default.json

# Audit: KMS calls recorded by CloudTrail (event history, last 2 hours)
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventSource,AttributeValue=kms.amazonaws.com \
  --start-time "$(date -u -d '-2 hours' +%Y-%m-%dT%H:%M:%SZ)" --max-results 50 \
  --query 'Events[].{Time:EventTime,Event:EventName,User:Username}' --output json | save cloudtrail-kms-events.json
echo "Evidence saved in $EVD"
