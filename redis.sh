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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling redis is "

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis is "

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis is"

systemctl enable redis
VALIDATE $? "enabling redis is"

systemctl start redis
VALIDATE $? "starting redis is"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connection to redis"

sed -i 's/^protected-mode\s\+yes/protected-mode no/g' /etc/redis/redis.conf
VALIDATE $? "updating protected mode"

systemctl restart redis
VALIDATE $? "Restarting redis is"