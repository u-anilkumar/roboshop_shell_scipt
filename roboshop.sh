#!/bin/bash

USER=$(id -u)
AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-03dde207ea3271219"
INS_TYPE="t3.micro"

if [ $USER -ne 0 ]; then
    echo "User doesnot have permission to run this script"
    exit 1
fi
for INSTANCE in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type $INS_TYPE \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value='$INSTANCE'}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
    echo "created $INSTANCE"
    
    if [ $INSTANCE == "frontend" ]; then

        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations.Instances.PublicIpAddress' \
        --output text)
        echo "Public IP address is $IP"
    
    else
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations.Instances.PrivateIpAddress' \
        --output text)
        echo "Private IP address is $IP"
    
    fi
    

done



