#!/bin/bash
# webserver instance installation 
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm

yum install wget vim python3 telnet htop git mysql net-tools chrony -y

systemctl start chronyd

systemctl enable chronyd
```
## configure selinux policies for the webservers and nginx servers
```
setsebool -P httpd_can_network_connect=1
setsebool -P httpd_can_network_connect_db=1
setsebool -P httpd_execmem=1
setsebool -P httpd_use_nfs 1
```
## this section will instll amazon efs utils for mounting the target on the Elastic file system
```
git clone https://github.com/aws/efs-utils

cd efs-utils

yum install -y make

yum install -y rpm-build

make rpm 

yum install -y  ./build/amazon-efs-utils*rpm


## seting up self-signed certificate for the apache  webserver instance

yum install -y mod_ssl

openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/smile.key -x509 -days 365 -out /etc/pki/tls/certs/smile.crt

#vi /etc/httpd/conf.d/ssl.conf



mkdir /var/www/
#file-system-id efs-mount-point efs _netdev,tls,accesspoint=access-point-id 0 0
sudo echo "fs-0bddc97bb0ec5017d /var/www/ efs _netdev,tls,accesspoint=fsap-005a3db9eeab27feb 0 0" >> /etc/fstab
sudo mount -a
#sudo mount -t efs -o tls,accesspoint=fsap-09f37dab8ffdfd8c6 fs-0c3e0574748f83c82:/ /var/www/
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
yum module reset php -y
yum module enable php:remi-7.4 -y
yum install -y php php-common php-mbstring php-opcache php-intl php-xml php-gd php-curl php-mysqlnd php-fpm php-json
systemctl start php-fpm
systemctl enable php-fpm
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
rm -rf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
mkdir /var/www/html/
cp -R wordpress/* /var/www/html/
cd /var/www/html/
touch healthstatus
sed -i "s/localhost/smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com/g" wp-config.php 
sed -i "s/username_here/smile/g" wp-config.php 
sed -i "s/password_here/admin123/g" wp-config.php 
sed -i "s/database_name_here/wordpressdb/g" wp-config.php 
#chcon -t httpd_sys_rw_content_t /var/www/html/ -R
systemctl restart httpd