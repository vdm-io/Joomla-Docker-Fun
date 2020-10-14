#!/bin/bash

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Docker Joomla Image Builder (2020)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2020. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

echo "Setting up Joomla"

cp /var/www/html/htaccess.txt /var/www/html/.htaccess

# Setup configuration file
cp /home/docker/scripts/configuration.php /var/www/html/configuration.php
sed -i "s/{WEBSITESNAME}/$WEBSITESNAME/g" /var/www/html/configuration.php
sed -i "s/{WEBSITESEMAIL}/$WEBSITESEMAIL/g" /var/www/html/configuration.php
sed -i "s/{DBDRIVER}/mysqli/g" /var/www/html/configuration.php
sed -i "s/{SMTPHOST}/$SMTPHOST/g" /var/www/html/configuration.php
sed -i "s/{DBHOST}/$DBHOST/g" /var/www/html/configuration.php
sed -i "s/{DBUSER}/$DBUSER/g" /var/www/html/configuration.php
sed -i "s/{DBPASS}/$DBPASS/g" /var/www/html/configuration.php
sed -i "s/{DBNAME}/$DBNAME/g" /var/www/html/configuration.php
sed -i "s/{DBPREFIX}/$DBPREFIX/g" /var/www/html/configuration.php

# Define install folder
installFolder=/var/www/html/installation

echo "Installing Joomla with mysql"

# Install joomla
mysql -u root -p $DBROOTPASS -h $DBHOST -e "drop database if exists $DBNAME"
mysql -u root -p $DBROOTPASS -h $DBHOST -e "create database $DBNAME"

if [ -f $installFolder/sql/mysql/joomla.sql ]; then
	sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/joomla.sql | mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME
else
	sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/base.sql | mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME
	sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/extensions.sql | mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME
	sed "s/#_/$DBPREFIX/g" $installFolder/sql/mysql/supports.sql | mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME
fi

# set the main user
PASSWORDHASH=$(getPassword $WEBSITESUSERPASS)
mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME -e "IERT INTO ${DBPREFIX}_users (id, name, username, email, password, block) VALUES(42, '${WEBSITESUNAME}', '${WEBSITESUSERNAME}', '${PASSWORDHASH}', '${PASSWORDHASH}', 0)"
mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME -e "INSERT INTO ${DBPREFIX}_user_usergroup_map (user_id, group_id) VALUES ('42', '8')"
# set the manager user?
mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME -e "INSERT INTO ${DBPREFIX}_users (id, name, username, email, password, block) VALUES(43, 'Manager', 'manager', 'manager@example.com', '\$2y\$10\$GICucf86nqR95Jz0mGTPkej8Mvzll/DRdXVClsUOkzyIPl6XF.2hS', 0)"
mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME -e "INSERT INTO ${DBPREFIX}_user_usergroup_map (user_id, group_id) VALUES ('43', '6')"
# set the basic user?
mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME -e "INSERT INTO ${DBPREFIX}_users (id, name, username, email, password, block) VALUES(44, 'User', 'user', 'user@example.com', '\$2y\$10\$KesDwI5C.oMfZksWG7UHaOP.1TWf91HTZPOi143qx2Tvc/8.hJIU.', 0)"
mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME -e "INSERT INTO ${DBPREFIX}_user_usergroup_map (user_id, group_id) VALUES ('44', '2')"

mysql -u $DBUSER -p $DBPASS -h $DBHOST -D $DBNAME -e "UPDATE ${DBPREFIX}_extensions SET manifest_cache='{\"version\":\"3\"}'"

# remove the instalation folder
rm -rf /var/www/html/installation

