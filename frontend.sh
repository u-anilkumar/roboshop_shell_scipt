#!/bin/bash
USER=$(id -u)
LOG_DIR=/var/log/frontend/
LOG_FILE=$LOG_DIR/$0.log
MONGO_HOST=mongodb.anildevops.online
CART_HOST=cart.anildevops.online
CATALOGUE_HOST=catalogue.anildevops.online
PAYMENT_HOST=payment.anildevops.online
USER_HOST=user.anildevops.online
SHIPPING_HOST=shipping.anildevops.online
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

dnf module enable nginx:1.24 -y
VALIDATE $? "enabling 1.24 version"

dnf install nginx -y
VALIDATE $? "installing nginx"

systemctl enable nginx
VALIDATE $? "enabling nginx"

systemctl start nginx
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Code download success"

cd /usr/share/nginx/html/

VALIDATE $? "moving to html directory"
unzip /tmp/frontend.zip
VALIDATE $? "unzipping frontend code"

mv nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Creating Nginx conf file" 

systemctl restart nginx 
VALIDATE $? "restarting Nginx" 