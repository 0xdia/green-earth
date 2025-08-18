#!/bin/bash

yum update -y
yum install -y git nginx python3 python3-pip
pip3 install virtualenv

git clone https://github.com/0xdia/green-earth.git /home/ec2-user/green-earth
chown -R ec2-user:ec2-user /home/ec2-user/green-earth

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
Environment="PATH=/home/ec2-user/green-earth/backend/venv/bin"
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

sudo rm -rf /usr/share/nginx/html/*
sudo cp -r /home/ec2-user/green-earth/frontend/* /usr/share/nginx/html/

sudo tee /etc/nginx/conf.d/frontend.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location ~ /health {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

sudo chown -R nginx:nginx /usr/share/nginx/html
sudo chmod -R 755 /usr/share/nginx/html

sudo systemctl restart nginx
