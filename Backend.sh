#!/binbash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo “please enter DB password”
read -s mysql_root_password”

Validate(){
	if [ $1 -ne 0 ]
	then
		echo "$2… $R FAILURE $N"
		exit 1
	else
		echo "$2… $G SUCCESS $N"
	fi
}
if [ $USERID -ne 0 ]
then
	echo "please run this script with root access"
	exit 1
else 
	echo "you are root user"
fi

dnf module disable nodejs -y &>>$LOGFILE
Validate $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
Validate $? "Enabling nodejs-20"

dnf install nodejs -y &>>$LOGFILE
Validate $? "Installing nodejs"

id expense &>>LOGFILE
if [ $? -ne 0 ]
then
	useradd expense &>>$LOGFILE
	Validate $? "Creating expense user"
else
	echo -e "expense already created… $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
Validate $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east 1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
Validate $? "downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
Validate $? "extracted backend code"

npm install &>>$LOGFILE
Validate $? "installing nodejs dependencies"

cp /home/ec2-user/expence-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
Validate $? "copied backend service"

systemctl daemon-reload &>>$LOGFILE
Validate $? "Deamon reload"

systemctl start backend &>>$LOGFILE
Validate $? "Starting backend service"

systemctl enable backend &>>$LOGFILE
Validate $? "Enabling backend service"

dnf install mysql -y &>>$LOGFILE
Validate $? "Installing myqsql clinet"

mysql -h db.eedula.shop -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
Validate $? "loading schema"

systemctl restart backend &>>$LOGFILE
Validate $? "Restarting Backend"
