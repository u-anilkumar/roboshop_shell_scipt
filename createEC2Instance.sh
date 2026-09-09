#!/bin/bash

#To create EC2, we need AMI id, security grouup id and instance type(t3.micro)
AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-03dde207ea3271219"
INS_TYPE="t3.micro"

aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INS_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$1'}]' \
    --query 'Instances[0].InstanceId' \
    --output text
