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

  sleep 5
  echo "Installing Joomla into Mysql"


  # Install joomla Database stuff
  mysql -u root -p"$DBRPASS" -h "$DBHOST" -e "drop database if exists $DBNAME;"
  mysql -u root -p"$DBRPASS" -h "$DBHOST" -e "create database $DBNAME;"
  mysql -u root -p"$DBRPASS" -h "$DBHOST" -e "create user '$DBUSER'@'%' identified with mysql_native_password;"
  mysql -u root -p"$DBRPASS" -h "$DBHOST" -e "grant all on $DBNAME.* to '$DBUSER'@'%';"
  mysql -u root -p"$DBRPASS" -h "$DBHOST" -e "set password for '$DBUSER'@'%' = PASSWORD('$DBPASS');"

  if [ -f $installFolder/sql/mysql/joomla.sql ]; then
    sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/joomla.sql | mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME"
  else
    sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/base.sql | mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME"
    sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/extensions.sql | mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME"
    sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/supports.sql | mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME"
  fi

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
  mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_users (id, name, username, email, password, registerDate, params, block) VALUES(${USERID}, '${WEBSITESUNAME}', '${WEBSITESUSERNAME}', '${WEBSITESEMAIL}', '${PASSWORDHASH}', '${TODAY}', '', 0)"
  mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_user_usergroup_map (user_id, group_id) VALUES ('${USERID}', '8')"
  # set the manager user?
  # mysql -u "$DBUSER" -p "$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_users (id, name, username, email, password, block) VALUES(43, 'Manager', 'manager', 'manager@example.com', '\$2y\$10\$GICucf86nqR95Jz0mGTPkej8Mvzll/DRdXVClsUOkzyIPl6XF.2hS', 0)"
  # mysql -u "$DBUSER" -p "$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_user_usergroup_map (user_id, group_id) VALUES ('43', '6')"
  # set the basic user?
  # mysql -u "$DBUSER" -p "$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_users (id, name, username, email, password, block) VALUES(44, 'User', 'user', 'user@example.com', '\$2y\$10\$KesDwI5C.oMfZksWG7UHaOP.1TWf91HTZPOi143qx2Tvc/8.hJIU.', 0)"
  # mysql -u "$DBUSER" -p "$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "INSERT INTO ${DBPREFIX}_user_usergroup_map (user_id, group_id) VALUES ('44', '2')"

  mysql -u "$DBUSER" -p"$DBPASS" -h "$DBHOST" -D "$DBNAME" -e "UPDATE ${DBPREFIX}_extensions SET manifest_cache='{\"version\":\"3\"}'"

  # remove the installation folder
  rm -rf /var/www/html/installation
fi
