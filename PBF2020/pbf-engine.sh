#!/bin/bash
clear;

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Joomla Pizza Bugs & Fun Docker Engine (2020)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2020. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

#█████████████████████████████████████████████████████████ Now deploy docker ███
while IFS=$'\t' read -r -a server
do
  # This will take a while (so run this in the background and come back later ;)
  ssh -tt -o ConnectTimeout=6 -o StrictHostkeyChecking=no root@${server[1]} "bash <(curl -s https://raw.githubusercontent.com/vdm-io/Joomla-Docker/main/PBF2020/pbf-helper.sh) && exit;"
done < ../servers.details
