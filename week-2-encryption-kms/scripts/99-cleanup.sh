#!/usr/bin/env bash
# Deletes all Week 2 resources. KMS keys get the minimum 7-day deletion window.
. "$(dirname "$0")/00-env.sh"
set +e
aws rds delete-db-instance --db-instance-identifier dp-lab-rds --skip-final-snapshot --delete-automated-backups >/dev/null && echo "RDS deleting"
aws dynamodb delete-table --table-name dp-lab-confidential >/dev/null && echo "DynamoDB deleted"
for v in $(aws ec2 describe-volumes --filters Name=tag:Name,Values=dp-lab-ebs --query 'Volumes[].VolumeId' --output text); do aws ec2 delete-volume --volume-id "$v" && echo "EBS $v deleted"; done
for B in "$CONF_BUCKET" "$REST_BUCKET"; do
  aws s3api head-bucket --bucket "$B" 2>/dev/null || continue
  aws s3api list-object-versions --bucket "$B" --output json > "$TMP/all.json"
  python3 -c 'import json,sys;d=json.load(open(sys.argv[1]));o=[{"Key":x["Key"],"VersionId":x["VersionId"]} for x in d.get("Versions",[])+d.get("DeleteMarkers",[])];json.dump({"Objects":o},open(sys.argv[2],"w"));print(len(o))' "$(p "$TMP/all.json")" "$(p "$TMP/v.json")" | grep -qv '^0$' && \
    aws s3api delete-objects --bucket "$B" --delete "file://$(p "$TMP/v.json")" >/dev/null
  aws s3api delete-bucket --bucket "$B" && echo "Bucket $B deleted"
done
aws iam delete-role-policy --role-name "$READER_ROLE" --policy-name read-restricted
aws iam delete-role --role-name "$READER_ROLE" && echo "Role deleted"
echo "Waiting for RDS deletion before scheduling key deletion..."
aws rds wait db-instance-deleted --db-instance-identifier dp-lab-rds
for a in "$CONF_ALIAS" "$REST_ALIAS"; do K=$(key_arn "$a" 2>/dev/null) || continue
  aws kms delete-alias --alias-name "$a"
  aws kms schedule-key-deletion --key-id "$K" --pending-window-in-days 7 --query '{Key:KeyId,DeletionDate:DeletionDate}' --output text
done
echo "Cleanup done."
