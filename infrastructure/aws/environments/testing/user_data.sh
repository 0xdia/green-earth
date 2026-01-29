#!/bin/bash

# setup
yum update -y
yum install -y git python3 python3-pip

# Install PostgreSQL client
sudo amazon-linux-extras enable postgresql14
sudo yum install -y postgresql

pip3 install virtualenv

git clone https://github.com/0xdia/green-earth.git /home/ec2-user/green-earth

# .env file with SSL fix
cat <<EOF > /home/ec2-user/green-earth/backend/.env
POSTGRES_HOST=${db_endpoint}
POSTGRES_DATABASE=${db_name}
POSTGRES_USER=${db_username}
POSTGRES_PASSWORD=${db_password}
AWS_REGION=${aws_region}
POPULATE_DB=true
POSTGRES_SSLMODE=require
EOF

# install
cd /home/ec2-user/green-earth/backend
python3 -m virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

# start service
cat <<EOF > /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/green-earth/backend
EnvironmentFile=/home/ec2-user/green-earth/backend/.env
ExecStart=/home/ec2-user/green-earth/backend/venv/bin/gunicorn --bind 0.0.0.0:5000 handler:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start flaskapp
systemctl enable flaskapp
