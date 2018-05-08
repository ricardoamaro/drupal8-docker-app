FROM ubuntu:bionic
MAINTAINER Ricardo Amaro <mail_at_ricardoamaro.com>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN apt-get -y install git curl wget supervisor openssh-server locales \
  mysql-client mysql-server apache2 pwgen vim-tiny mc iproute2 python-setuptools \
  unison netcat net-tools memcached nano libapache2-mod-php php php-cli php-common \
  php-gd php-json php-mbstring php-xdebug php-mysql php-opcache php-curl \
  php-readline php-xml php-memcached; \
  apt-get clean; \
  apt-get autoclean; \
  apt-get -y autoremove

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

# SSH fix for permanent local login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
#RUN sed -i '/SendEnv LANG/d'  /etc/ssh/ssh_config
RUN locale-gen en_US.UTF-8
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install empty data folder
RUN rm -rf /var/lib/mysql/*; /usr/sbin/mysqld --initialize-insecure

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Drush & Drupal Console
RUN HOME=/ /usr/local/bin/composer global require drush/drush:~8 \
  && ln -s /.composer/vendor/drush/drush/drush /usr/local/bin/drush
RUN curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal

# Display version information
RUN php --version; composer --version; drupal --version; drush --version

# Install supervisor
COPY ./files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./files/start.sh /start.sh
COPY ./files/foreground.sh /etc/apache2/foreground.sh

# Apache & Xdebug
RUN rm /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/*
ADD ./files/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default ; a2enmod rewrite vhost_alias
ADD ./files/xdebug.ini /etc/php5/mods-available/xdebug.ini

# Drupal new version, clean cache
ADD https://updates.drupal.org/release-history/drupal/8.x /tmp/latest.xml

# Retrieve drupal
RUN /bin/bash -t
RUN cd /var/www/html; drush -v dl drupal --default-major=8 --drupal-project-rename="web"
RUN cd /var/www/html; chmod a+w web/sites/default; mkdir web/sites/default/files; chown -R www-data:www-data /var/www/html/

# Manage db with adminer
RUN wget "http://www.adminer.org/latest.php" -O /var/www/html/web/adminer.php

# Set some permissions
RUN mkdir -p /var/run/mysqld; chown mysql:mysql /var/run/mysqld
RUN chmod 755 /start.sh /etc/apache2/foreground.sh
WORKDIR /var/www/html
EXPOSE 22 80 3306 9000
CMD ["/bin/bash", "/start.sh"]
