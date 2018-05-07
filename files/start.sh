#!/bin/bash

GRPID=$(stat -c "%g" /var/www/html/)

export DRUSH="/.composer/vendor/drush/drush/drush"
export LOCAL_IP=$(hostname -I| awk '{print $1}')
export HOSTIP=$(/sbin/ip route | awk '/default/ { print $3 }')
echo "${HOSTIP} dockerhost" >> /etc/hosts

# Create a basic mysql install
if [ ! -d /var/lib/mysql/mysql ]; then
  echo "**** No MySQL data found. Creating data on /var/lib/mysql/ ****"
  mysqld --initialize-insecure
  chown -R mysql:${GRPID} /var/lib/mysql
  chmod -R ug+ws /var/lib/mysql
else
  echo "**** MySQL data found on /var/lib/mysql/ ****"
fi

# Start supervisord
supervisord -c /etc/supervisor/conf.d/supervisord.conf -l /tmp/supervisord.log

# If there is no index.php, download drupal
if [ ! -f /var/www/html/index.php ]; then
  echo "**** No Drupal found. Downloading latest to /var/www/html/ ****"
  cd /var/www/html;
  /.composer/vendor/drush/drush/drush -vy dl drupal \
  --default-major=8 --drupal-project-rename="."
  chmod a+w /var/www/html/sites/default;
  mkdir /var/www/html/sites/default/files;
  wget "http://www.adminer.org/latest.php" -O /var/www/html/adminer.php
  chown -R www-data:${GRPID} /var/www/html/
else
  echo "**** /var/www/html/index.php found  ****"
fi

# Setup Drupal if settings.php is missing
if [ ! -f /var/www/html/sites/default/settings.php ]; then
	# Generate random passwords
	DRUPAL_DB="drupal"
  DEBPASS=$(grep password /etc/mysql/debian.cnf |head -n1|awk '{print $3}')
	ROOT_PASSWORD=`pwgen -c -n -1 12`
	DRUPAL_PASSWORD=`pwgen -c -n -1 12`
	echo ${ROOT_PASSWORD} > /var/lib/mysql/mysql/mysql-root-pw.txt
	echo ${DRUPAL_PASSWORD} > /var/lib/mysql/mysql/drupal-db-pw.txt
  # Wait for mysql
  while ! nc -z localhost 3306; do sleep 0.1; done
  # Create and change MySQL creds
	mysqladmin -u root password ${ROOT_PASSWORD} 2>/dev/null
  mysql -uroot -p${ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DEBPASS';" 2>/dev/null
	mysql -uroot -p${ROOT_PASSWORD} -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'%' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;" 2>/dev/null
	cd /var/www/html
	cp sites/default/default.services.yml sites/default/services.yml
	${DRUSH} site-install standard -y --account-name=admin --account-pass=admin \
  --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal" \
  --site-name="Drupal8 docker App" | grep -v 'continue?' 2>/dev/null
	${DRUSH} -y dl memcache | grep -v 'continue?' 2>/dev/null
	${DRUSH} -y en memcache | grep -v 'continue?' 2>/dev/null
else
  echo "**** /var/www/html/sites/default/settings.php found ****"
	ROOT_PASSWORD=$(cat /var/lib/mysql/mysql/mysql-root-pw.txt)
	DRUPAL_PASSWORD=$(cat /var/lib/mysql/mysql/drupal-db-pw.txt)
fi

# Change root password
echo "root:${ROOT_PASSWORD}" | chpasswd

# Clear caches and reset files perms
chown -fR www-data:${GRPID} /var/www/html/
chmod -R ug+ws /var/www/html/
(sleep 3; drush --root=/var/www/html/ cache-rebuild 2>/dev/null) &

echo

echo "------------------------- GENERATED USERS CREDENTIALS --------------------------------"
echo
echo "    DRUPAL:  http://${LOCAL_IP}              with user/pass: admin/admin"
echo
echo "    MYSQL :  http://${LOCAL_IP}/adminer.php  drupal/${DRUPAL_PASSWORD} or root/${ROOT_PASSWORD}"
echo "    SSH   :  ssh root@${LOCAL_IP}            with user/pass: root/${ROOT_PASSWORD}"
echo
echo "  Please report any issues to https://github.com/ricardoamaro/drupal8-docker-app"
echo "  USE CTRL+C TO STOP THIS APP"
echo
echo "------------------------------STARTING SERVICES---------------------------------------"

tail -f /tmp/supervisord.log
# supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
# /bin/bash
