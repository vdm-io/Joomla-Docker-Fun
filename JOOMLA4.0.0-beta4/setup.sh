#!/bin/bash

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Docker Joomla Base Image Builder (2020)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2020. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

# make sure the directory is empty
rm -rf /var/www/html/*
# get the latest Joomla
git clone --depth 1 --branch 4.0.0-beta4 https://github.com/joomla/joomla-cms.git /var/www/html 2>&1 > /dev/null
# change to the website root
cd /var/www/html/
# should not be here, but...
if [ -f /var/www/html/libraries/autoload_psr4.php ]; then
	rm -f /var/www/html/libraries/autoload_psr4.php
fi
echo "Installing PHP dependencies"
composer install
# Run npm
echo "Installing the assets (takes a while!)"
npm ci
