#!/bin/bash
#check root user or not
USER=$(id -u)
LOG_DIR=/var/log/mongoDB/
LOG_FILE=$LOG_DIR/$0.log
MONGO_HOST=mongodb.anildevops.online

#enable colours
R='\e[31m'
G='\e[32m'
N='\e[0m'
Y='\e[33m'

if [ $USER -ne 0 ]; then
    echo "You do not have permission to run this script"
    exit 1
fi


# write validate fnction to verify status
VALIDATE()
{
    if [ $1 -eq 0 ]; then
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
    fi

}

mkdir -p $LOG_DIR
VALIDATE $? "Log Directory Creation is"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Mongo repo creation is"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Mongodb installation is"

systemctl enable mongod
VALIDATE $? "Mongodb enable is"

systemctl start mongod
VALIDATE $? "Starting MongoDB is"

#Update mongo config to open it to internet
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connection to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB is"



