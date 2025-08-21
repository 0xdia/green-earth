#!/bin/bash

AWS_REGION="${aws_region}"
export AWS_REGION

yum update -y
yum install -y git nginx python3 python3-pip
pip3 install virtualenv

git clone https://github.com/0xdia/green-earth.git /home/ec2-user/green-earth
chown -R ec2-user:ec2-user /home/ec2-user/green-earth

# Get database credentials from passed parameters
PROJECT_NAME="${project_name}"
DB_ENDPOINT="${db_endpoint}"
DB_NAME="${db_name}"
DB_USERNAME="${db_username}"
DB_PASSWORD="${db_password}"

POPULATE_DB=true
export POPULATE_DB

# Create environment file
cat << EOF > /home/ec2-user/green-earth/backend/.env
POSTGRES_HOST=$${DB_ENDPOINT}
POSTGRES_DATABASE=$${DB_NAME}
POSTGRES_USER=$${DB_USERNAME}
POSTGRES_PASSWORD=$${DB_PASSWORD}
AWS_REGION=$${AWS_REGION}
EOF

chown ec2-user:ec2-user /home/ec2-user/green-earth/backend/.env

cd /home/ec2-user/green-earth/backend
python3 -m virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

cat <<EOF > /etc/systemd/system/flaskapp.service
[Unit]
Description=Gunicorn instance for Flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/green-earth/backend
EnvironmentFile=/home/ec2-user/green-earth/backend/.env
ExecStart=/home/ec2-user/green-earth/backend/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 handler:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/flaskapp.service
chown -R ec2-user:ec2-user /home/ec2-user/green-earth

systemctl daemon-reload
systemctl start flaskapp
systemctl enable flaskapp
