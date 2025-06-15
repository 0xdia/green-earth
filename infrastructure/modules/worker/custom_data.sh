#!/bin/bash

# Install required packages
curl https://bootstrap.pypa.io/get-pip.py > get-pip.py
python3 get-pip.py

# instal docker
wget https://raw.githubusercontent.com/docker/docker-install/refs/heads/master/install.sh
chmod +x install.sh
./install.sh

# Install Postgres client
apt install postgresql-client

# Create directory and content
mkdir -p /web-content
cat > /web-content/health.html <<EOF
<h1>Health Check</h1>
EOF

cat > /web-content/index.html <<EOF
<h1>Simple Python Server</h1>
EOF

# Create systemd service for persistence
sudo tee /etc/systemd/system/simple-server.service > /dev/null <<EOF
[Unit]
Description=Simple Python Web Server

[Service]
ExecStart=/usr/bin/python3 -m http.server 9090 --directory /web-content
WorkingDirectory=/web-content
User=$(whoami)
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable simple-server
systemctl start simple-server

mkdir -p /root/data

# Create environment file
echo "
# PostgreSQL
DRUPAL_DATABASE_TYPE=postgresql
DRUPAL_DATABASE_HOST=drupal-db-srv.postgres.database.azure.com
DRUPAL_DATABASE_PORT=5432
DRUPAL_DATABASE_NAME=drupaldb
DRUPAL_DATABASE_USER=drupaldbadmin
DRUPAL_DATABASE_PASSWORD=your_secure_password
# DRUPAL_DATABASE_SSL_ENABLED=true
# DRUPAL_DATABASE_SSL_MODE=require

# Disable MySQL checks
DRUPAL_DATABASE_HOST_MYSQL=
DRUPAL_DATABASE_PORT_NUMBER_MYSQL=
" | sudo tee /root/.env
