#!/bin/bash
# webserver instance installation 
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm

yum install wget vim python3 telnet htop git mysql net-tools chrony -y

systemctl start chronyd

systemctl enable chronyd

## configure selinux policies for the webservers and nginx servers

setsebool -P httpd_can_network_connect=1
setsebool -P httpd_can_network_connect_db=1
setsebool -P httpd_execmem=1
setsebool -P httpd_use_nfs 1

## this section will instll amazon efs utils for mounting the target on the Elastic file system

git clone https://github.com/aws/efs-utils

cd efs-utils

yum install -y make

yum install -y rpm-build

make rpm 

yum install -y  ./build/amazon-efs-utils*rpm

## seting up self-signed certificate for the apache  webserver instance

yum install -y mod_ssl

openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/ACS.key -x509 -days 365 -out /etc/pki/tls/certs/ACS.crt

#vi /etc/httpd/conf.d/ssl.conf




# Login into the RDS instnace  and create  database for wordpress and tooling wordpress and tooling database
#mysql -h acs-database.cdqpbjkethv0.us-east-1.rds.amazonaws.com -u ACSadmin -p 

#CREATE DATABASE toolingdb;
#CREATE DATABASE wordpressdb;
mkdir /var/www/
sudo echo "fs-0c3e0574748f83c82 /var/www/ efs _netdev,tls,accesspoint=fsap-0113338d48d1fced8 0 0" >> /etc/fstab
mount -a
#sudo mount -t efs -o tls,accesspoint=fsap-0336048fbb5688cc2 fs-08618216c6f97b55e:/ /var/www/
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
yum module reset php -y
yum module enable php:remi-7.4 -y
yum install -y php php-common php-mbstring php-opcache php-xml php-gd php-curl php-mysqlnd php-fpm php-json
systemctl start php-fpm
systemctl enable php-fpm
git clone https://github.com/nbomasi/tooling-1.git
mkdir /var/www/html
cp -R tooling-1/html/*  /var/www/html/
mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u webaccess -padmin123 tooling < tooling-1/tooling-db.sql
cd /var/www/html/
touch healthstatus
sed -i "s/$db = mysqli_connect('mysql.tooling.svc.cluster.local', 'admin', 'admin', 'tooling');/$db = mysqli_connect('smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com', 'webaccess', 'admin123', 'tooling');/g" functions.php
#chcon -t httpd_sys_rw_content_t /var/www/html/ -R
systemctl restart httpd
