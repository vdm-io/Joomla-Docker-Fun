#!/bin/bash
clear;

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Joomla Pizza Bugs & Fun Engine (2020)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2020. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

# we need sshpass
command -v sshpass >/dev/null 2>&1 || { echo "sshpass NOT installed. Aborting!"; exit 1; }

# start the parallel file
> ../servers.parallel
# simple basic random
function getPassword () {
    echo $(tr -dc 'A-HJ-NP-Za-km-z2-9' < /dev/urandom | dd bs=15 count=1 status=none)
}

# the remote docker deploy script
function remoteDockerDeploy(){
  bash <(curl -s https://raw.githubusercontent.com/vdm-io/Joomla-Docker/main/PBF2020/pbf-helper.sh)
}

#█████████████████████████████████████████ Add the config details to servers ███
while IFS=$'\t' read -r -a server
do
  password=$(getPassword)
  password2=$(getPassword)
  echo "We build the ${server[2]} config, and push it to the server"
  # reset file
  echo "### WEBSITE CONTAINER #################################" > config.properties

  # we rest the instance, this will force all docker containers/images/volumes to be removed
  echo "container.reset=1" >> config.properties
  echo "# the container main domain" >> config.properties
  echo "container.website.domain=${server[2]}" >> config.properties
  echo "# the generic website name" >> config.properties
  echo "container.website.websitename=\"Joomla! Pizza Bugs and Fun\"" >> config.properties
  echo "# the generic name of a user" >> config.properties
  echo "container.website.uname=\"Joomla Hero\"" >> config.properties
  echo "# the generic useruser" >> config.properties
  echo "container.website.username=${server[3]}" >> config.properties
  echo "# the generic user password" >> config.properties
  echo "container.website.userpass=${server[4]}" >> config.properties
  echo "# should the user be asked to reset their password" >> config.properties
  echo "container.website.passreset=1" >> config.properties
  echo "# the generic user and site email" >> config.properties
  echo "container.website.email=\"${server[3]}@email.com\"" >> config.properties
  echo "# should we add the patch tester" >> config.properties
  echo "container.website.addpatchtester=1" >> config.properties
  echo "# the database generic settings" >> config.properties
  echo "container.website.dbdriver=mysqli" >> config.properties
  echo "container.website.dbhost=mysql" >> config.properties
  echo "container.website.dbuser=website_user" >> config.properties
  echo "container.website.dbpass=${password}" >> config.properties
  echo "container.website.dbrootpass=${password2}" >> config.properties
  echo "container.website.dbname=joomla_db" >> config.properties
  echo "container.website.dbprefix=jpbf" >> config.properties
  echo "# the email generic settings" >> config.properties
  echo "container.website.smtphost=mailcatcher" >> config.properties
  echo "container.website.sslemail=joomla+ssl@vdm.io" >> config.properties
  echo "# the port generic settings" >> config.properties
  echo "container.website.portweb=80" >> config.properties
  echo "container.website.portwebssl=443" >> config.properties
  echo "container.website.portpam=81" >> config.properties
  echo "container.website.portmc=82" >> config.properties
  echo "# the volumes generic settings" >> config.properties
  echo "container.website.volwebroot=web-root" >> config.properties
  echo "container.website.voldbhost=db-data" >> config.properties
  # now we move the config to the server
  sshpass -p ${server[0]} scp config.properties root@${server[1]}:config.properties
done < ../servers.details

# we make sure no config.properties file remains
rm -f config.properties
