FROM vdmio/php:7.4-apache-node12

MAINTAINER Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>

# Website User Details
ENV WEBSITEDOMAIN=joomla.vdm \
    WEBSITESNAME="Joomla - VDM" \
    WEBSITESUNAME="Joomla Method" \
    WEBSITESUSERNAME=method \
    WEBSITESUSERPASS=vastdevelopmentmethod \
    WEBSITESPASSRESET=0 \
    WEBSITESEMAIL="joomla@example.com" \
# Website database details
    DBDRIVER=mysqli \
    DBHOST=mysql \
    DBUSER=vdm \
    DBPASS=vastdevelopmentmethod \
    DBROOTPASS=vastdevelopmentmethod \
    DBNAME=joomla \
    DBPREFIX=vdm \
# Website email details
    SMTPHOST=mailcatcher \
    SSLEMAIL="joomla+ssl@vdm.io" \
# Ports
    PORTWEB=80 \
    PORTSSL=443 \
    PORTPAM=81 \
    PORTMC=82 \
# Network
    CONTAINERSUBNET=172.16.0.0/24 \
# Volumes
    VOLWEBROOT=web-root \
    VOLDBHOST=db-data \
    LOCALPATH=~/ \
# Packages
    PACKAGEJOOMA="https://github.com/joomla/joomla-cms/releases/download/4.0.0-rc2/Joomla_4.0.0-rc2-Release_Candidate-Full_Package.zip"

# load setup script
RUN mkdir /home/docker/scripts

# move the scripts into place
COPY docker-entrypoint.sh /usr/local/bin/deploy_joomla
COPY configuration.php.tmpl /home/docker/scripts/configuration.php
COPY packages.vdm /home/docker/scripts/packages.vdm

# run the setup script
RUN sudo chmod +x /usr/local/bin/deploy_joomla
