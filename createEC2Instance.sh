#!/bin/bash


VALIDATE(){
    if [ $1 -eq 0 ]; then
    echo "$2 ... SUCCESS"
    else
    echo "$2 ... FAILURE"
    fi
    }

#To create EC2, we need AMI id, security grouup id and instance type(t3.micro)
AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-03dde207ea3271219"
INS_TYPE="t3.micro"
HOST_ZONE_ID="Z0124704QJP234EU1AXQ"
DOMAIN="anildevops.online"

for INSTANCE in $@
do
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INS_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$INSTANCE'}]' \
    --query 'Instances[0].InstanceId' \
    --output text) 

VALIDATE $? "INSTANCE Creation with name $INSTANCE "    
echo "Instance name is $INSTANCE and Instance id is $INSTANCE_ID"



if [ $INSTANCE == frontend ]; then
    IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
    VALIDATE $? "Public IP Creation "  
    DNS_NAME=$DOMAIN
    echo "Public IP is $IP"
else
    IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)
    VALIDATE $? "IP Creation "  
    DNS_NAME=$INSTANCE.$DOMAIN
    echo "Private IP is $IP"
fi

aws route53 change-resource-record-sets \
    --hosted-zone-id $HOST_ZONE_ID \
    --change-batch '{
        "Comment": "Updating A record to new IP",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": '$DNS_NAME',
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                        {
                            "Value": '$IP'
                        }
                    ]
                }
            }
        ]
    }'

done



