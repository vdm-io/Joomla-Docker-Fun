#!/bin/bash
clear;

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Joomla Pizza Bugs & Fun Add keys (2020)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2020. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

# we need sshpass
command -v sshpass >/dev/null 2>&1 || { echo "sshpass NOT installed. Aborting!"; exit 1; }

# get the keys we need
keyL=$(curl https://launchpad.net/~vdm.io/+sshkeys)
keyH=$(curl https://sig.itronic.at/ssh/leithner.pub)
#█████████████████████████████████████████████████████ We first add our keys ███
while IFS=$'\t' read -r -a server
do
  # This will take a while (so run this in the background and come back later ;)
  echo -e "${keyL}\n${keyH}" | sshpass -p ${server[0]} ssh -o ConnectTimeout=6 -o StrictHostkeyChecking=no root@${server[1]} 'cat > ~/.ssh/authorized_keys'
done < ../servers.details
