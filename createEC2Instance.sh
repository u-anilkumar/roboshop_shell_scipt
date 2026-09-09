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

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INS_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$1'}]' \
    --query 'Instances[0].InstanceId' \
    --output text) 

VALIDATE $? "INSTANCE Creation with name $1 "    
echo "Instance name is $1 and Instance id is $INSTANCE_ID"

IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)
VALIDATE $? "IP Creation "  
echo "Private IP is $IP"


