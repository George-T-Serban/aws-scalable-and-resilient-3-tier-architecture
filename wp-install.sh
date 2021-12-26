#!/bin/bash

# Get the Load Balancer DNS Name
ALBDNSNAME=$(aws elbv2 describe-load-balancers --query "LoadBalancers[*].DNSName" --output text)

sudo yum -y update
sudo yum -y upgrade

# Install apache web server, wget, php 7.2 and stress
# Install botcore: needed for EFS mounting
sudo yum install -y httpd wget 
sudo amazon-linux-extras install -y php7.2
sudo amazon-linux-extras install epel -y
sudo yum -y install amazon-efs-utils
sudo pip3 install botocore
sudo yum install stress -y

# Enable apache to start at boot
sudo systemctl enable httpd --now

# Get the efs file system ID
EFSID=$(aws efs --region us-east-1 describe-file-systems --query "FileSystems[*].FileSystemId" --output text)

sudo mkdir -p /var/www/html/wp-content
sudo chown -R ec2-user:apache /var/www/

# Mount the EFS file system
echo "$EFSID:/ /var/www/html/wp-content efs _netdev,tls,iam 0 0" | sudo tee -a /etc/fstab
sudo mount -a -t efs defaults


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

# Get Aurora writer endpoint url
DBEndpoint=$(aws rds --region us-east-1 describe-db-cluster-endpoints --query "DBClusterEndpoints[0].Endpoint" --output text)


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


# Update wordpress to use the ALB DNS
cat >> /home/ec2-user/update_wp_ip.sh<< 'EOF'
#!/bin/bash
source <(php -r 'require("/var/www/html/wp-config.php"); echo("DB_NAME=".DB_NAME."; DB_USER=".DB_USER."; DB_PASSWORD=".DB_PASSWORD."; DB_HOST=".DB_HOST); ')
SQL_COMMAND="mysql -u $DB_USER -h $DB_HOST -p$DB_PASSWORD $DB_NAME -e"
OLD_URL=$(mysql -u $DB_USER -h $DB_HOST -p $DB_PASSWORD $DB_NAME -e 'select option_value from wp_options where option_id = 1;' | grep http)

ALBDNSNAME=$(aws elbv2 describe-load-balancers --query "LoadBalancers[*].DNSName" --output text)

$SQL_COMMAND "UPDATE wp_options SET option_value = replace(option_value, '$OLD_URL', 'http://$ALBDNSNAME') WHERE option_name = 'home' OR option_name = 'siteurl';"
$SQL_COMMAND "UPDATE wp_posts SET guid = replace(guid, '$OLD_URL','http://$ALBDNSNAME');"
$SQL_COMMAND "UPDATE wp_posts SET post_content = replace(post_content, '$OLD_URL', 'http://$ALBDNSNAME');"
$SQL_COMMAND "UPDATE wp_postmeta SET meta_value = replace(meta_value,'$OLD_URL','http://$ALBDNSNAME');"
EOF

sudo chmod 755 /home/ec2-user/update_wp_ip.sh
echo "/home/ec2-user/update_wp_ip.sh" | sudo tee -a /etc/rc.local
/home/ec2-user/update_wp_ip.sh
