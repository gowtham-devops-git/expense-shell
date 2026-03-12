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
        echo " $2 .... is success"
        exit 1
    else
        echo " $2 ... is failed"
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

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql"

dnf enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling mysql"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql"

mysql -h 172.31.30.229 -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo " MySQL Root password is not set" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password"
else
    echo "Mysql root password already setup .. Skipping"
fi 