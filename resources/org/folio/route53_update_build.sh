#!/bin/bash

# ec2_group
group_tag=$1
base_build=$2
#base_build=$(awk -F '_' '{ print $1 "-" $2}'<<< $group_tag)

# 'latest' or 'stable'
build=$3

export PATH=/usr/local/bin:$PATH

#hostname=$(awk -F '_' '{ print $1 "-" $2 "-" $3}'<<< $group_tag)
hostname=$(sed -e 's/_/-/g' <<< $group_tag)
hostname_base=$(sed -e 's/_/-/g' <<< $base_build)

aws="aws --output text --region us-east-1"
public_zoneid="Z2F9IQRBHKK7BO"
private_zoneid="Z3JKLZ9JDZ7HCP"

public_record=$(cat <<EOF
{
"Comment": "Update public zone record to reflect latest ${hostname_base}-${build}",
  "Changes": [
    { 
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${hostname_base}-${build}.aws.indexdata.com.",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [
          { 
            "Value": "${hostname}.aws.indexdata.com"
          }
        ]
      }
   }
 ]
}
EOF
)

private_record=$(cat <<EOF
{
"Comment": "Update internal zone record to reflect latest ${hostname_base}-${build}",
  "Changes": [
    { 
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${hostname_base}-${build}.indexdata.internal.",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [
          { 
            "Value": "${hostname}.indexdata.internal"
          }
        ]
      }
   }
 ]
}
EOF
)

echo "Posting CNAME record for ${base_build}-${build}.aws.indexdata.com to AWS route53:" 
echo "$public_record"
echo "$public_record" > public_record.out
$aws route53 change-resource-record-sets --hosted-zone-id $public_zoneid --change-batch file://public_record.out

echo "Posting CNAME record for ${base_build}-${build}.indexdata.internal to AWS route53:" 
echo "$private_record"
echo "$private_record" > private_record.out
$aws route53 change-resource-record-sets --hosted-zone-id $private_zoneid --change-batch file://private_record.out
