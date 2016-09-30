FROM ubuntu:trusty
MAINTAINER Ricardo Amaro <mail_at_ricardoamaro.com>
ENV DEBIAN_FRONTEND noninteractive

#RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN apt-get -y install git curl wget supervisor openssh-server \
  mysql-client mysql-server apache2 libapache2-mod-php5 pwgen \
  vim-tiny mc python-setuptools unison memcached php5-memcache \
  php5-cli php5-mysql php-apc php5-gd php5-curl php5-xdebug; \
  apt-get clean; \
  apt-get autoclean; \
  apt-get -y autoremove

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

# SSH fix for permanent local login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed -i '/SendEnv LANG/d'  /etc/ssh/ssh_config
RUN locale-gen en_US.UTF-8
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install Composer & Drush
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Drush, Drupal Console and pimp-my-log
RUN HOME=/ /usr/local/bin/composer global require drush/drush:~8; \
  HOME=/ /usr/local/bin/composer global require drupal/console:dev-master; \
  HOME=/ /usr/local/bin/composer require "potsky/pimp-my-log"

# Install supervisor
COPY ./files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./files/start.sh /start.sh
COPY ./files/foreground.sh /etc/apache2/foreground.sh

#Apache & Xdebug
RUN rm /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/*
ADD ./files/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default ; a2enmod rewrite vhost_alias
ADD ./files/xdebug.ini /etc/php5/mods-available/xdebug.ini

# Display version information
RUN php --version
RUN composer --version
RUN /.composer/vendor/drush/drush/drush --version && ln -s /.composer/vendor/drush/drush/drush /usr/bin/drush

# Drupal new version, clean cache
ADD https://www.drupal.org/project/drupal /tmp/latest.html

# Retrieve drupal
RUN rm -rf /var/www/html ; cd /var/www ; /.composer/vendor/drush/drush/drush -v dl drupal --default-major=8 --drupal-project-rename="html"
RUN chmod a+w /var/www/html/sites/default ; mkdir /var/www/html/sites/default/files ; chown -R www-data:www-data /var/www/html/

#Manage db with adminer
RUN wget "http://www.adminer.org/latest.php" -O /var/www/html/adminer.php

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
WORKDIR /var/www/html
EXPOSE 22 80 3306 9000
CMD ["/bin/bash", "/start.sh"]
