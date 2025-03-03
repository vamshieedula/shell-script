#!/binbash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install nginx -y &>>$LOGFILE
Validate $? "installing nginx"

systemctl enable nginx &>>$LOGFILE
Validate $? "enabling nginx"

systemctl start nginx &>>$LOGFILE
Validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
Validate $? "removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
Validate $? "downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
Validate $? "extracting frontend code"

cp /home/ec2-user/shell-script/expense.conf /etc/nginx/default.d/expence.conf &>>$LOGFILE
Validate $? "copied expense conf"

systemctl restart nginx &>>$LOGFILE
Validate $? "restarting nginx"
