#!/bin/bash
clear;

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Joomla Pizza Bugs & Fun Helper (2020)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2020. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

#███████████████████████████████████████████████████ Function - GET PROPERTY ███
# the main config file
PROPERTYFILE="config.properties"
# we must upload this file first! (since its private)
# before triggering this script
if [ ! -f "$PROPERTYFILE" ]; then
  echo "First upload your config.properties file to the server before running this script"; exit 1;
fi
# to get the properties from our config
function getProperty {
	if [ -f $PROPERTYFILE ]
	then
		PROP_KEY=$1
		PROP_VALUE=`cat $PROPERTYFILE | grep "$PROP_KEY" | cut -d'=' -f2`
		echo $PROP_VALUE
	fi
}
# this script just works on centOS
osName=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ "$osName" != "\"CentOS Linux\"" ]]; then
  echo "This script only works on CentOS Linux"; exit 1;
fi
# first we stop Apache (pain)
sudo systemctl stop httpd
sudo systemctl disable httpd
# only install/setup docker once
command -v docker >/dev/null 2>&1 || {
  # remove old docker
  sudo yum remove docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine
  # make sure we have utils
  sudo yum install -y yum-utils git nano
  # add docker repo
  sudo yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo
  # now install docker
  sudo yum install -y docker-ce docker-ce-cli containerd.io
  sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  # start docker
  sudo systemctl start docker
  # persist docker
  sudo systemctl enable docker
  # make sure the user is in the docker group
  sudo usermod -aG docker $USER
}
# check if we should reset the container
RESETCONTAINER=$(getProperty "container.reset")
if [ "$RESETCONTAINER" -eq "1" ]; then
  # we remove all docker stuff, to force a deep update
  docker stop joomla phpmyadmin mailcatcher mysql certbot
  docker rm joomla phpmyadmin mailcatcher mysql certbot -f
  docker rmi vdmio/joomla:4.0.0-beta4 vdmio/joomla:4.0.0-beta5 phpmyadmin/phpmyadmin schickling/mailcatcher mysql:5.7 certbot/certbot -f
  docker volume rm root_db-data root_web-root
fi
# remove old composer file if found
if [ -f docker-compose.yml ]
then
  rm -f docker-compose.yml
fi
# next we get our blank composer template file
curl -L 'https://raw.githubusercontent.com/vdm-io/Joomla-Docker/main/PBF2020/docker-compose.yml.tmpl' -o docker-compose.yml
# Get Website Details
WEBSITEDOMAIN=$(getProperty "container.website.domain")
WEBSITESNAME=$(getProperty "container.website.websitename")
WEBSITESUNAME=$(getProperty "container.website.uname")
WEBSITESUSERNAME=$(getProperty "container.website.username")
WEBSITESUSERPASS=$(getProperty "container.website.userpass")
WEBSITESPASSRESET=$(getProperty "container.website.passreset")
WEBSITESEMAIL=$(getProperty "container.website.email")
WEBSITESADDPATCHTESTER=$(getProperty "container.website.addpatchtester")
DBDRIVER=$(getProperty "container.website.dbdriver")
DBHOST=$(getProperty "container.website.dbhost")
DBUSER=$(getProperty "container.website.dbuser")
DBPASS=$(getProperty "container.website.dbpass")
DBROOTPASS=$(getProperty "container.website.dbrootpass")
DBNAME=$(getProperty "container.website.dbname")
DBPREFIX=$(getProperty "container.website.dbprefix")
SMTPHOST=$(getProperty "container.website.smtphost")
SSLEMAIL=$(getProperty "container.website.sslemail")
PORTWEB=$(getProperty "container.website.portweb")
PORTSSL=$(getProperty "container.website.portssl")
PORTPAM=$(getProperty "container.website.portpam")
PORTMC=$(getProperty "container.website.portmc")
VOLWEBROOT=$(getProperty "container.website.volwebroot")
VOLDBHOST=$(getProperty "container.website.voldbhost")
# Packages
# PACKAGEJOOMA=$(getProperty "joomla.image.packagejoomla.url")
# PACKAGEPATCHTESTER=$(getProperty "joomla.image.packagepatchtester.url")
# place details in our yml file
dockerComposeFile="docker-compose.yml"
sed -i "s/{WEBSITEDOMAIN}/$WEBSITEDOMAIN/g" "$dockerComposeFile"
sed -i "s/{WEBSITESNAME}/$WEBSITESNAME/g" "$dockerComposeFile"
sed -i "s/{WEBSITESUNAME}/$WEBSITESUNAME/g" "$dockerComposeFile"
sed -i "s/{WEBSITESUSERNAME}/$WEBSITESUSERNAME/g" "$dockerComposeFile"
sed -i "s/{WEBSITESUSERPASS}/$WEBSITESUSERPASS/g" "$dockerComposeFile"
sed -i "s/{WEBSITESPASSRESET}/$WEBSITESPASSRESET/g" "$dockerComposeFile"
sed -i "s/{WEBSITESEMAIL}/$WEBSITESEMAIL/g" "$dockerComposeFile"
sed -i "s/{WEBSITESADDPATCHTESTER}/$WEBSITESADDPATCHTESTER/g" "$dockerComposeFile"
sed -i "s/{DBDRIVER}/$DBDRIVER/g" "$dockerComposeFile"
sed -i "s/{DBHOST}/$DBHOST/g" "$dockerComposeFile"
sed -i "s/{DBUSER}/$DBUSER/g" "$dockerComposeFile"
sed -i "s/{DBPASS}/$DBPASS/g" "$dockerComposeFile"
sed -i "s/{DBROOTPASS}/$DBROOTPASS/g" "$dockerComposeFile"
sed -i "s/{DBNAME}/$DBNAME/g" "$dockerComposeFile"
sed -i "s/{DBPREFIX}/$DBPREFIX/g" "$dockerComposeFile"
sed -i "s/{SMTPHOST}/$SMTPHOST/g" "$dockerComposeFile"
sed -i "s/{SSLEMAIL}/$SSLEMAIL/g" "$dockerComposeFile"
sed -i "s/{PORTWEB}/$PORTWEB/g" "$dockerComposeFile"
sed -i "s/{PORTSSL}/$PORTSSL/g" "$dockerComposeFile"
sed -i "s/{PORTPAM}/$PORTPAM/g" "$dockerComposeFile"
sed -i "s/{PORTMC}/$PORTMC/g" "$dockerComposeFile"
sed -i "s/{VOLWEBROOT}/$VOLWEBROOT/g" "$dockerComposeFile"
sed -i "s/{VOLDBHOST}/$VOLDBHOST/g" "$dockerComposeFile"
# Run docker compose
docker-compose up -d
# done, all should now run (following commands will show you more)
# docker ps
# docker images
# docker volume ls
