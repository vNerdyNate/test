#!/bin/bash
#Web Setup
apt-get update
apt-get install -y apache2
apt install -y php
apt install -y php-mysql
apt install -y libapache2-mod-php
apt install -y mysql-client
mkdir -p /var/www/html/wordpress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz 
tar -xzf /var/www/html/latest.tar.gz -C /var/www/html/wordpress --strip-components 1
for i in {1..5}; do mysql --connect-timeout=3 -h 10.150.166.20 -u root -pmysqlpassword -e "SHOW STATUS;" && break || sleep 15; done
mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -i -e s/"define( 'DB_NAME', 'database_name_here' );"/"define( 'DB_NAME', 'wordpress_blog' );"/ /var/www/html/wordpress/wp-config.php 
sed -i -e s/"define( 'DB_USER', 'username_here' );"/"define( 'DB_USER', 'ubuntu' );"/ /var/www/html/wordpress/wp-config.php 
sed -i -e s/"define( 'DB_PASSWORD', 'password_here' );"/"define( 'DB_PASSWORD', 'mysqlpassword' );"/ /var/www/html/wordpress/wp-config.php 
sed -i -e s/"define( 'DB_HOST', 'localhost' );"/"define( 'DB_HOST', '10.150.166.20' );"/ /var/www/html/wordpress/wp-config.php
service apache2 restart
