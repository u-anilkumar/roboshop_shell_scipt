#!/bin/bash
LOG_DIR=/var/log/shipping/
LOG_FILE=$LOG_FILE/$0.log
MYSQL_HOST=shipping.anildevops.online
WD=$PWD
#enable colours
R='\e[31m'
G='\e[32m'
N='\e[0m'
Y='\e[33m'


USER=$(id -u)
if [ $USER -ne 0 ]; then
    echo "You do not have permission to run this script"
    exit 1
fi

VALIDATE()
{
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
    else
        echo -e "$2 ..$G SUCCESS $N" | tee -a $LOG_FILE

    fi

}

mkdir -p $LOG_DIR
VALIDATE $? "LOG dir creation"

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing JAVA"

mkdir -p /app
VALIDATE $? "App directory creation"

#Create system USER
id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin roboshop &>>$LOG_FILE
else 
    echo -e "Roboshop user already exists $Y SKIPPING $N"
fi

cd /app
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Code download"

rm -rf /app/*
VALIDATE $? "removing existing code"
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping code"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "moving shipping jar file to app directory"

#create systemctl service

cp $WD/shippping.service /etc/systemd/system/shipping.service
VALIDATE $? "creating systemctl service"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable shipping
VALIDATE $? "enable shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "installing sql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "Loading schema"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALIDATE $? "Loading appuser"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "Loading master data which has cities and countries"

systemctl start shipping
VALIDATE $? "starting shipping"



