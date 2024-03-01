#!/bin/bash
DATABASE_PASS='admin12345'
#sudo yum update -y
#sudo yum install mysql -y
#sudo yum install git zip unzip -y


# starting & enabling mysql-server
#sudo systemctl start mysqld
#sudo systemctl enable mysqld
#cd /tmp/
#git clone -b main https://github.com/hkhcoder/vprofile-project.git
#restore the dump file for the application
#sudo mysqladmin -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin password "$DATABASE_PASS"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "create database tooling"
#sudo mysql -h tooling-db.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "create user'ehi'@'%' identified by 'admin123'"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "CREATE USER 'webaccess'@'%' IDENTIFIED BY 'admin123'"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "grant all privileges on tooling.* TO 'webaccess'@'%'"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "create database wordpressdb"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "CREATE USER 'smile'@'%' IDENTIFIED BY 'admin123'"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "grant all privileges on wordpressdb.* TO 'smile'@'%'"
sudo mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com -u admin -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

git clone https://github.com/nbomasi/tooling-1.git
git clone https://github.com/dareyio/tooling.git
mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com  -u webaccess -p"$DATABASE_PASS" tooling < tooling-1/tooling-db.sql
#mysql -h smile-rds.cn0qacy4c7da.eu-north-1.rds.amazonaws.com  -u boma -p"$DATABASE_PASS" toolingdb < tooling/html/tooling_db_schema.sql
