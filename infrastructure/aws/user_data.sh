#!/bin/bash

yum update -y
yum install -y git nginx python3 python3-pip
pip3 install virtualenv

git clone https://github.com/0xdia/green-earth.git /home/ec2-user/green-earth
chown -R ec2-user:ec2-user /home/ec2-user/green-earth


export POSTGRES_HOST=${db_endpoint}
export POSTGRES_DATABASE=${db_name}
export POSTGRES_USER=${db_username}
export POSTGRES_PASSWORD=${db_password}
export AWS_REGION=${aws_region}
export POPULATE_DB=true


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
