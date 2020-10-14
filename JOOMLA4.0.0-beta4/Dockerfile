FROM vdmio/php:7.4-apache-node12

MAINTAINER Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>

# load setup script
RUN mkdir /home/docker/scripts
COPY setup.sh /home/docker/scripts/setup.sh
COPY configuration.php.tmpl /home/docker/scripts/configuration.php

# now run the setup script (to load Joomla to the image)
RUN sudo chmod +x /home/docker/scripts/setup.sh
RUN /home/docker/scripts/setup.sh
