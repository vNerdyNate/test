#!/bin/bash
#SQL Setup
apt install -y mysql-server
sed -e '/bind-address/ s/^#*/#/' -i /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY 'mysqlpassword';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';"
mysql -e "CREATE USER 'ubuntu'@'%' IDENTIFIED BY 'mysqlpassword';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'%';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "create database wordpress_blog;"
