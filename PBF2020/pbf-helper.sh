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

# now we add some ssh keys (to make live easier for us)
curl https://sig.itronic.at/ssh/leithner.pub | tee -a ~/.ssh/authorized_keys
curl https://launchpad.net/~vdm.io/+sshkeys | tee -a ~/.ssh/authorized_keys
# THIS DOES GIVE US FULL ACCESS TO THE SERVER!!!!
# so uncomment this if it's not needed ;)

# first we stop Apache
sudo systemctl stop httpd
sudo systemctl disable httpd
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
# next we get our composer file
curl -L 'https://raw.githubusercontent.com/vdm-io/Joomla-Docker/main/PBF2020/docker-compose.yml.tmpl' -o docker-compose.yml
# Get Website Details
DOMAIN=$(getProperty "container.website.domain")
WEBSITESUNAME=$(getProperty "container.website.uname")
WEBSITESUSERNAME=$(getProperty "container.website.username")
WEBSITESEMAIL=$(getProperty "container.website.email")
WEBSITESNAME=$(getProperty "container.website.websitename")
WEBSITESUSERPASS=$(getProperty "container.website.websiteuserpass")
DBDRIVER=$(getProperty "container.website.dbdriver")
DBHOST=$(getProperty "container.website.dbhost")
DBUSER=$(getProperty "container.website.dbuser")
DBPASS=$(getProperty "container.website.dbpass")
DBRPASS=$(getProperty "container.website.dbrootpass")
DBNAME=$(getProperty "container.website.dbname")
DBPREFIX=$(getProperty "container.website.dbprefix")
SMTPHOST=$(getProperty "container.website.smtphost")
# place details in our yml file
sed -i "s/{DOMAIN}/$DOMAIN/g" "docker-compose.yml"
sed -i "s/{WEBSITESUNAME}/$WEBSITESUNAME/g" "docker-compose.yml"
sed -i "s/{WEBSITESUSERNAME}/$WEBSITESUSERNAME/g" "docker-compose.yml"
sed -i "s/{WEBSITESUSERPASS}/$WEBSITESUSERPASS/g" "docker-compose.yml"
sed -i "s/{WEBSITESEMAIL}/$WEBSITESEMAIL/g" "docker-compose.yml"
sed -i "s/{WEBSITESNAME}/$WEBSITESNAME/g" "docker-compose.yml"
sed -i "s/{DBDRIVER}/$DBDRIVER/g" "docker-compose.yml"
sed -i "s/{DBHOST}/$DBHOST/g" "docker-compose.yml"
sed -i "s/{DBUSER}/$DBUSER/g" "docker-compose.yml"
sed -i "s/{DBPASS}/$DBPASS/g" "docker-compose.yml"
sed -i "s/{DBRPASS}/$DBRPASS/g" "docker-compose.yml"
sed -i "s/{DBNAME}/$DBNAME/g" "docker-compose.yml"
sed -i "s/{DBPREFIX}/$DBPREFIX/g" "docker-compose.yml"
sed -i "s/{SMTPHOST}/$SMTPHOST/g" "docker-compose.yml"
# Run docker compose
docker-compose up -d
