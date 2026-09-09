#!/bin/bash
USER=$(id -u)
LOG_DIR=/var/log/catalogue/
LOG_FILE=$LOG_DIR/$0.log
MONGO_HOST=mongodb.anildevops.online
WD=$PWD

#enable colours
R='\e[31m'
G='\e[32m'
N='\e[0m'
Y='\e[33m'


if [ $USER -ne 0 ]; then
    echo "You do not have permission to run this script"
    exit 1
fi

VALIDATE()
{
    if [ $1 -eq 0 ]; then
        echo -e "$2 ... $G SUCCESS $N"
    else
        echo -e "$2 ...$G FAILURE $N"

    fi
}

mkdir -p $LOG_DIR 
VALIDATE $? "LOG directory creation is"

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS is "

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS is "

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS is"

id roboshop
if [ $? -ne 0 ]; then
    #Create SYSTEM USER
    useradd --system --home /app --shell /sbin/nologin roboshop
    VALIDATE $? "USER creation is"
else 
    echo -e "Roboshop user already exists $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "APP dir creation is"

#download code to tmp directory
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Code download is "

cd /app
VALIDATE $? "moving to app directory "

rm -rf /app/*
VALIDATE $? "removing existing code "
UNZIP /tmp/catalogue.zip
VALIDATE $? "unzipping code"

#install dependecies
npm install &>>$LOG_FILE
VALIDATE $? "installing dependecies"
#create systemmctl file
cp $WD/catalogue.sh /etc/systemd/system/catalogue.service

systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable catalogue
VALIDATE $? "enabling catalogue"

systemctl start catalogue
VALIDATE $? "starting catalogue"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongo client"

INDEX=$(mongosh --host $MONGO_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then
    mongosh --host $MONGO_HOST </app/db/master-data.js
    VALIDATE $? "LOADING products"
else
    echo -e "Products already loaded $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "restarting catalogue"







