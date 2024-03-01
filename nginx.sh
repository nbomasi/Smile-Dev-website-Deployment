
#!/bin/bash
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

## seting up self-signed certificate for the nginx instance

sudo mkdir /etc/ssl/private

sudo chmod 700 /etc/ssl/private

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/smile.key -out /etc/ssl/certs/smile.crt

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048


yum install -y nginx
systemctl start nginx
systemctl enable nginx
git clone https://github.com/nbomasi/BOMA-PBL-PROJECT-15-20.git
mv BOMA-PBL-PROJECT-15-20/BOMA-PBL-PROJECT-15-20/project-15-AWS/userdata-files/reverse.conf /etc/nginx/
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf-distro
cd /etc/nginx/
touch nginx.conf
sed -n 'w nginx.conf' reverse.conf
systemctl restart nginx
rm -rf reverse.conf
#rm -rf /DevOps-AWS-Cloud

