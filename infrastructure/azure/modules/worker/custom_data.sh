#!/bin/bash

# Create directory and health file
mkdir -p /var/www/health
echo "OK" > /var/www/health/health.html

# Start a Python HTTP server on port 9090 in the background
nohup python3 -m http.server 9090 --directory /var/www/health > /dev/null 2>&1 &

sudo apt-get update
sudo apt-get install -y python3-pip

git clone https://github.com/0xdia/green-earth.git
pip3 install -r green-earth/backend/requirements.txt
