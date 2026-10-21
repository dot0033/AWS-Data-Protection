#!/usr/bin/env bash
# Encrypts DynamoDB, EBS and RDS with the confidential CMK. Smallest sizes; delete with 99-cleanup.sh.
. "$(dirname "$0")/00-env.sh"
CONF_KEY=$(key_arn "$CONF_ALIAS")
TAGS="Key=DataClassification,Value=confidential Key=Owner,Value=security-team Key=Environment,Value=lab"

echo "RDS (starts first, takes ~10 min)"
if ! aws rds describe-db-instances --db-instance-identifier dp-lab-rds >/dev/null 2>&1; then
  aws rds create-db-instance --db-instance-identifier dp-lab-rds --engine postgres \
    --db-instance-class db.t3.micro --allocated-storage 20 --storage-type gp2 \
    --master-username dpadmin --master-user-password "$(openssl rand -hex 16)" \
    --storage-encrypted --kms-key-id "$CONF_KEY" --backup-retention-period 0 \
    --no-multi-az --no-publicly-accessible --no-deletion-protection \
    --tags $TAGS >/dev/null
fi

echo "DynamoDB"
if ! aws dynamodb describe-table --table-name dp-lab-confidential >/dev/null 2>&1; then
  aws dynamodb create-table --table-name dp-lab-confidential \
    --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST --sse-specification Enabled=true,SSEType=KMS,KMSMasterKeyId="$CONF_KEY" \
    --tags Key=DataClassification,Value=confidential Key=Owner,Value=security-team Key=Environment,Value=lab >/dev/null
fi

echo "EBS (1 GiB, not attached)"
if [ -z "$(aws ec2 describe-volumes --filters Name=tag:Name,Values=dp-lab-ebs --query 'Volumes[].VolumeId' --output text)" ]; then
  aws ec2 create-volume --availability-zone "${AWS_REGION}a" --size 1 --volume-type gp3 \
    --encrypted --kms-key-id "$CONF_KEY" \
    --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=dp-lab-ebs},{Key=DataClassification,Value=confidential},{Key=Owner,Value=security-team},{Key=Environment,Value=lab}]" >/dev/null
fi

aws dynamodb wait table-exists --table-name dp-lab-confidential
aws dynamodb put-item --table-name dp-lab-confidential --item '{"id":{"S":"rec-001"},"note":{"S":"fake confidential record"}}'
echo "Waiting for RDS..."
aws rds wait db-instance-available --db-instance-identifier dp-lab-rds
echo "Done."
