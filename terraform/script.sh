#!/bin/bash
sudo yum update -y && sudo yum install -y httpd
echo "Healthy response from $(hostname)" | sudo tee /var/www/html/index.html
echo "Script executed on $(date)" | sudo tee -a /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd