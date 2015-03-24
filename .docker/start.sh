#!/bin/bash

mkdir -p /var/www/wordpress-core
mkdir -p /var/www/wordpress-content/plugins
mkdir -p /var/www/wordpress-content/themes
mkdir -p /var/www/wordpress-content/uploads
mkdir -p /var/log/app/wordpress
mkdir -p /var/log/app/supervisor
mkdir -p /var/log/app/mysqld
touch /var/log/app/php5-fpm.log
chown www-data:www-data /var/log/app/php5-fpm.log
supervisord -n -c /etc/supervisord.conf