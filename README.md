# Docker Image Builder/Deployer of Joomla4 v1

## What does this script do
This script can build Joomla docker images, and deploy, multiple instances/containers of these images behind a [Traefik proxy](https://doc.traefik.io/traefik/), and setup [Portainer](https://www.portainer.io/installation/) to manage these docker containers.

You need [Docker](https://docs.docker.com/engine/install/) installed, and then make sure the user that runs this script has permission to run docker. Also make sure you do not have another service listening at port 80, so stop Apache or the [Traefik](https://doc.traefik.io/traefik/) container will give an error.

## To run
__Before__ you run this script setup your __config.properties__ using the __config.tmpl__ as your example.
```bash
$ clone https://github.com/vdm-io/Joomla-Docker.git
$ cd Joomla-Docker
$ sudo chmod +x run.sh
$ ./run.sh -f config.properties
```

# Shout-out to:
- [Thecodingmachine PHP docker project](https://github.com/thecodingmachine/docker-images-php)
- [Digital-Peak](https://github.com/Digital-Peak/DPDocker)
- [Joomla Console Project](https://github.com/joomlatools/joomlatools-console)


```txt
Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
Copyright (C) 2019. All Rights Reserved
GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
```
