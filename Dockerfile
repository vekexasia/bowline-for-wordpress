FROM ubuntu:14.04
MAINTAINER Eugene Ware <me@andreabaccega.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# Basic Requirements
RUN apt-get -y install php5-fpm php5-mysql php-apc pwgen python-setuptools curl git unzip
RUN apt-get -y install apache2 apache2-utils libapache2-mod-php5
RUN apt-get -y install mysql-client
# Wordpress Requirements
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

RUN a2enmod rewrite
RUN a2enmod auth_basic
# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout

ADD .docker/etc/supervisord.conf /etc/supervisord.conf
ADD .docker/etc/default-site /etc/apache2/sites-enabled/000-default.conf
RUN mkdir -p /var/www/bin

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN mv wp-cli.phar /var/www/bin/wp
RUN chmod +x /var/www/bin/wp
#ADD ./wordpress-core/ /var/www/wordpress
#ADD ./logs/ /var/www/logs

# Install Wordpress

# Wordpress Initialization and Startup Script
ADD ./bin/fix-perms /var/www/bin/fix-perms
ADD ./lib/bowline /var/www/lib/bowline
ADD .docker/composer.json /var/www/composer.json

ADD .docker/start.sh /start.sh
ADD .docker/etc/apache_foreground.sh /etc/apache2/foreground.sh
ADD .docker/wp-cli.yml /var/www/wp-cli.yml

RUN chmod 755 /start.sh /etc/apache2/foreground.sh /var/www/bin/fix-perms
RUN chown www-data:www-data /var/www/wp-cli.yml

# private expose

