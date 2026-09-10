#!/bin/bash
LOG_DIR=/var/log/mysql/
LOG_FILE=$LOG_FILE/$0.log
MYSQL_HOST=mysql.anildevops.online
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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Mysql server installation"

systemctl enable mysqld
VALIDATE $? "enabling Mysql server "

systemctl start mysqld
VALIDATE $? "starting Mysql server "

mysql_secure_installation --set-root-pass RoboShop@1
#set root password
