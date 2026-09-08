#!/bin/bash
export PATH=$PATH:/usr/local/bin
USER=$(id -u)
AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-03dde207ea3271219"
INS_TYPE="t3.micro"
LOG_DIR="/var/log/roboshop/"
LOG_FILE=$LOG_DIR/$0.log

if [ $USER -ne 0 ]; then
    echo "User doesnot have permission to run this script" 
    exit 1
fi

VALIDATE()
{
    if [ $1 -eq 0 ]; then
        echo "$2 .... SUCCESS"
    else 
        echo "$2 ... FAILURE"
        
    fi

}

mkdir -p $LOG_DIR
VALIDATE $? "Log dir creation"

for INSTANCE in $@
do
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INS_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value='$INSTANCE'}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
        
VALIDATE $? "$INSTANCE Creation is"

echo "created $INSTANCE" | tee -a $LOG_FILE

if [ $INSTANCE == "frontend" ]; then

        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations.Instances.PublicIpAddress' \
        --output text)

        VALIDATE $? "IP Creation is"
        echo "Public IP address is $IP"  | tee -a $LOG_FILE
    
else
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations.Instances.PrivateIpAddress' \
        --output text) &>> $LOG_FILE
        VALIDATE $? "IP Creation is"
        echo "Private IP address is $IP"  | tee -a $LOG_FILE
    
fi
    

done



