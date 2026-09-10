#!bin/bash
LOG_DIR=/var/log/payment/
LOG_FILE=$LOG_DIR/$0.log
WD=$PWD

USER=$(id -u)
if [ $USER -ne 0 ]; then
    echo "You donot have permission to run this script"
fi

VALIDATE()
{
    if [ $1 -ne 0]; then
        echo -e "$2 is .. $R FAILURE $N"
    else
        echo -e "$2 is ..$G SUCCESS $N"
    fi 
}

mkdir -p $LOG_DIR
VALIDATE $? "LOG Dir creation"

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing PYTHON"

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
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Code download"

rm -rf /app/*
VALIDATE $? "removing existing code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping code"

pip3 install -r requirements.txt
VALIDATE $? "Installing dependencies"

cp $WD/payment.service /etc/systemd/system/payment.service
VALIDATE $? "creating systemctl service"

systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable payment
VALIDATE $? "enabling payment"

systemctl start payment
VALIDATE $? "starting payment"
