#!/binbash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please enter DB password"
read -s "mysql_root_password"
Validate(){
        if [ $1 -ne 0 ]
        then
                echo -e "$2… $R FAILURE $N"
                exit 1
        else
                echo -e "$2… $G SUCCESS $N"
        fi
}
if [ $USERID -ne 0 ]
then
        echo "please run this script with root access"
        exit 1
else
        echo "you are root user"
fi

dnf install mysql-server –y &>>$LOGFILE
Validate $? "Installing Mysql server"

systemctl enable mysqld &>>$LOGFILE
Validate $? "Enabling Mysql server"

systemctl start mysqld &>>$LOGFILE
Validate $? "starting Mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#Validate $? "Setting up root password"

#below code is useful for idempotent nature
mysql -h db.eedula.shop -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ]
then
	mysql_secure_installation --set-root-pass ${mysql_root_password} &>>LOGFILE
	Validate $? “Root password setup”
else
	echo -e "Mysql Root password is already setup… $Y SKIPPIING $N"
fi
