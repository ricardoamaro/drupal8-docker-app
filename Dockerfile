# docker Drupal8
# VERSION         1
# DOCKER-VERSION  1
FROM    ubuntu:trusty
MAINTAINER Ricardo Amaro <mail_at_ricardoamaro.com>
ENV DEBIAN_FRONTEND noninteractive

#RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN apt-get -y install git curl wget mysql-client mysql-server \
  apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny \
  php5-mysql php-apc php5-gd php5-curl php5-memcache memcached mc
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get -y autoremove

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

# Install Composer & Drush
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 
RUN HOME=/ /usr/local/bin/composer global require drush/drush:dev-master

# Install supervisor
RUN easy_install supervisor
ADD ./files/start.sh /start.sh
ADD ./files/foreground.sh /etc/apache2/foreground.sh
ADD ./files/supervisord.conf /etc/supervisord.conf
RUN rm /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/*
ADD ./files/000-default.conf /etc/apache2/sites-available/000-default.conf 
RUN a2ensite 000-default
RUN a2enmod rewrite vhost_alias

# Display version information
RUN php --version
RUN composer --version
RUN /.composer/vendor/drush/drush/drush --version

# Retrieve drupal
RUN rm -rf /var/www/html ; cd /var/www ; /.composer/vendor/drush/drush/drush -v dl drupal --default-major=8 --drupal-project-rename="html"
RUN chmod a+w /var/www/html/sites/default ; mkdir /var/www/html/sites/default/files ; chown -R www-data:www-data /var/www/html/

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
#ENTRYPOINT ["composer", "--ansi"]
