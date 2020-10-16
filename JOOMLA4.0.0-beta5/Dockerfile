FROM vdmio/php:7.4-apache-node12

MAINTAINER Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>

# Website User Details
ENV WEBSITEDOMAIN=builder.vdm \
    WEBSITESNAME="Joomla - VDM" \
    WEBSITESUNAME="Joomla Method" \
    WEBSITESUSERNAME=method \
    WEBSITESUSERPASS=vastdevelopmentmethod \
    WEBSITESPASSRESET=0 \
    WEBSITESEMAIL="joomla@example.com" \
    WEBSITESADDPATCHTESTER=1 \
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
# Volumes
    VOLWEBROOT=web-root \
    VOLDBHOST=db-data \
# Packages
    PACKAGEJOOMA="https://developer.joomla.org/nightlies/Joomla_4.0.0-beta5-dev-Development-Full_Package.zip" \
    PACKAGEPATCHTESTER="https://github.com/joomla-extensions/patchtester/releases/download/4.0.0/com_patchtester.zip"

# load setup script
RUN mkdir /home/docker/scripts

# move the scripts into place
COPY docker-entrypoint.sh /usr/local/bin/deploy_joomla
COPY configuration.php.tmpl /home/docker/scripts/configuration.php

# run the setup script
RUN sudo chmod +x /usr/local/bin/deploy_joomla

# Download package and extract to web volume
RUN set -ex; \
	curl -o joomla.zip -SL ${PACKAGEJOOMA}; \
	unzip -d /var/www/html joomla.zip; \
	# we use zip for now
	# tar -xf joomla.tar.bz2 -C /var/www/html; \
	rm joomla.zip
