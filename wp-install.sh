#!/bin/bash

sudo yum -y update
sudo yum -y upgrade

# Install apache web server, wget, php 7.2 and stress
sudo yum install -y httpd wget 
sudo amazon-linux-extras install -y php7.2
sudo amazon-linux-extras install epel -y
sudo yum install stress -y

# Enable apache to start at boot
sudo systemctl enable httpd --now

# Download and extract Wordpress
sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .
sudo rm -R wordpress
sudo rm latest.tar.gz

# Get database credentials from AWS SSM Parameter Store
DBPassword=$(aws ssm get-parameters --region us-east-1 --names DBPassword --with-decryption --query Parameters[0].Value --output text)

DBRootPassword=$(aws ssm get-parameters --region us-east-1 --names DBRootPassword --with-decryption --query Parameters[0].Value --output text)

DBUser=$(aws ssm get-parameters --region us-east-1 --names DBUser --query Parameters[0].Value --output text)

DBName=$(aws ssm get-parameters --region us-east-1 --names DBName --query Parameters[0].Value --output text)

# Get database endpoint url
DBEndpoint=$(aws rds --region us-east-1 describe-db-instances --query "DBInstances[*].Endpoint.Address" --output text)


# Configure the wordpress wp-config.php file
sudo cp ./wp-config-sample.php ./wp-config.php
sudo sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sudo sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sudo sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sudo sed -i "s/'localhost'/'$DBEndpoint'/g" wp-config.php

#Fix Permissions on the filesystem
sudo usermod -a -G apache ec2-user   
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;