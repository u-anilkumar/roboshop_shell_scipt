#!bin/bash
LOG_DIR=/var/log/rabbit/
LOG_FILE=$LOG_DIR/$0.log
WD=$PWD
#enable colours
R='\e[31m'
G='\e[32m'
N='\e[0m'
Y='\e[33m'

USER=$(id -u)
if [ $USER -ne 0 ]; then

    echo "You donot have permission to run this script"
    exit 1
fi

VALIDATE()
{
    if [ $1 -ne 0 ]; then
        echo -e "$2 is .. $R FAILURE $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ..$G SUCCESS $N" | tee -a $LOG_FILE
    fi 
}

mkdir -p $LOG_DIR
VALIDATE $? "LOG Dir creation"

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "copying repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing RabbitMQ"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enabling RabbitMQ"
systemctl start rabbitmq-server
VALIDATE $? "starting RabbitMQ"

rabbitmqctl list_users | grep -q "^roboshop[[:space:]]"

if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
else
    echo -e " User already exists $Y SKIPPING $N"
fi



