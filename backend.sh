#!/bin/bash



USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | cut -d "%" -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%s)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo " $2 .... is failed"
        exit 1
    else
        echo " $2 ... is sucess"
    fi
}


CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then 
        echo " ERROR Please the run the script with the root user"
    fi
}

echo "script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT


dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling node js"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling nodeJs"

dnf install nodejs -y  &>>$LOG_FILE_NAME
VALIDATE $? "installing nodeJs" 

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOG_FILE_NAME
else
    echo -e "expense user already exists .. $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading backend"


cd /app
rm rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzip backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

mysql -h 172.31.30.229 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transactions schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon Reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling backend"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting Backend"


