#!/bin/bash

export DRUSH="/.composer/vendor/drush/drush/drush"

if [ ! -f /var/www/html/sites/default/settings.php ]; then
	# Start mysql
	/usr/bin/mysqld_safe --skip-syslog & 
	sleep 5s
	# Generate random passwords 
	DRUPAL_DB="drupal"
	MYSQL_PASSWORD=`pwgen -c -n -1 12`
	DRUPAL_PASSWORD=`pwgen -c -n -1 12`
	# This is so the passwords show up in logs. 
	echo "-----MYSQL USERS CREDENTIALS-------"
	echo "mysql root   password: $MYSQL_PASSWORD"
	echo "mysql drupal password: $DRUPAL_PASSWORD"
	echo $MYSQL_PASSWORD > /mysql-root-pw.txt
	echo $DRUPAL_PASSWORD > /drupal-db-pw.txt
	echo "-----------------------------------"
	mysqladmin -u root password $MYSQL_PASSWORD 
	mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
	cd /var/www/html
	cp sites/default/default.services.yml sites/default/services.yml
	${DRUSH} site-install standard -y --account-name=admin --account-pass=admin --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"
	${DRUSH} -y dl memcache
	${DRUSH} -y en memcache
	killall mysqld
	sleep 10s
fi
supervisord -n
