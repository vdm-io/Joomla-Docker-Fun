#!/bin/bash

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Docker Joomla Base Image Builder (2020)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2020. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

# Define install folder
installFolder=/var/www/html/installation

# Define administrator folder
adminFolder=/var/www/html/administrator

# check if we have the Joomla files, or download it now
if [ ! -d "$adminFolder" ]; then
    curl -o joomla.zip -SL ${PACKAGEJOOMA}; \
    unzip -d /var/www/html joomla.zip; \
    # we use zip for now
    # tar -xf joomla.tar.bz2 -C /var/www/html; \
    rm joomla.zip
fi

# simple basic random
function getRandomString () {
    echo $(tr -dc 'A-HJ-NP-Za-km-z' < /dev/urandom | dd bs=15 count=1 status=none)
}

# if the installation dir is not available
# then we already have done an install
# could be that an persistence volume is being used
if [ -d "$installFolder" ]; then
  echo "Setting up Joomla"

  # we need to wait just a few seconds for the Mysql te get ready...
  # this is not the best idea
  # any help here will be great
  sleep 15

  cp /var/www/html/htaccess.txt /var/www/html/.htaccess

  # Move the CLI Install Script into Place
  # cp /home/docker/scripts/vdmInstallExtension.php /var/www/html/cli/vdmInstallExtension.php

  # set the random Joomla secret
  JOOMLASECRET=$(getRandomString)

  # Setup configuration file
  cp /home/docker/scripts/configuration.php /var/www/html/configuration.php
  sed -i "s/{WEBSITESNAME}/$WEBSITESNAME/g" /var/www/html/configuration.php
  sed -i "s/{WEBSITESEMAIL}/$WEBSITESEMAIL/g" /var/www/html/configuration.php
  sed -i "s/{DBDRIVER}/$DBDRIVER/g" /var/www/html/configuration.php
  sed -i "s/{SMTPHOST}/$SMTPHOST/g" /var/www/html/configuration.php
  sed -i "s/{DBHOST}/$DBHOST/g" /var/www/html/configuration.php
  sed -i "s/{DBUSER}/$DBUSER/g" /var/www/html/configuration.php
  sed -i "s/{DBPASS}/$DBPASS/g" /var/www/html/configuration.php
  sed -i "s/{DBNAME}/$DBNAME/g" /var/www/html/configuration.php
  sed -i "s/{DBPREFIX}/$DBPREFIX/g" /var/www/html/configuration.php
  sed -i "s/{JOOMLASECRET}/$JOOMLASECRET/g" /var/www/html/configuration.php

  # we add more waiting options
  maxcounter=45
  counter=1
  while ! mysql --protocol TCP -u root -p"$DBROOTPASS" -h "$DBHOST" -e "show databases;" > /dev/null 2>&1; do
      sleep 1
      counter=`expr $counter + 1`
      if [ $counter -gt $maxcounter ]; then
	   >&2 echo "We have been waiting for MySQL too long already; failing."
	   exit 1
      fi;
  done
  echo "Installing Joomla into Mysql"

  # Install joomla Database stuff
  mysql -u root -p"$DBROOTPASS" -h "$DBHOST" -e "drop database if exists $DBNAME;"
  mysql -u root -p"$DBROOTPASS" -h "$DBHOST" -e "create database $DBNAME;"
  mysql -u root -p"$DBROOTPASS" -h "$DBHOST" -e "create user '$DBUSER'@'%' identified with mysql_native_password;"
  mysql -u root -p"$DBROOTPASS" -h "$DBHOST" -e "grant all on $DBNAME.* to '$DBUSER'@'%';"
  mysql -u root -p"$DBROOTPASS" -h "$DBHOST" -e "set password for '$DBUSER'@'%' = PASSWORD('$DBPASS');"

  sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/base.sql | mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME"
  sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/extensions.sql | mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME"
  sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/supports.sql | mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME"

  # I would like to also tweak the install with our own SQL

  # gives us the password hashed and ready for the database
  function getPassword(){
    pass=$1
    salt=`< /dev/urandom tr -dc "A-Za-z0-9" | head -c32`
    hash=$(echo -n $pass$salt | openssl md5)
    pass="$hash:$salt"
    echo ${pass#*= }
  }

  # set the main user
  PASSWORDHASH=$(getPassword "$WEBSITESUSERPASS")
  USERID=$(( $RANDOM % 10 + 40 ))
  TODAY=$(date '+%Y-%m-%d %H:%M:%S') # 2020-10-15 00:00:00
  mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_users (id, name, username, email, password, registerDate, params, block, requireReset) VALUES(${USERID}, '${WEBSITESUNAME}', '${WEBSITESUSERNAME}', '${WEBSITESEMAIL}', '${PASSWORDHASH}', '${TODAY}', '', 0, '${WEBSITESPASSRESET}')"
  mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_user_usergroup_map (user_id, group_id) VALUES ('${USERID}', '8')"

  mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "UPDATE ${DBPREFIX}_extensions SET manifest_cache='{\"version\":\"3\"}'"

  # remove the installation folder
  rm -rf /var/www/html/installation

  # we want to install components
  if [ -f "/home/docker/scripts/packages.vdm" ]; then
    while read ZIP_URL; do
      php /var/www/html/cli/joomla.php extension:install --url "$ZIP_URL"
      # the above would have been ideal...
    done < /home/docker/scripts/packages.vdm
  fi
fi
