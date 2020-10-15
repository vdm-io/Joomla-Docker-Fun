# To Deploy Docker Images to Many Servers

## What does this script do
This script `./pbf-engine.sh` will build website config files based on the `servers.details` values, and move them to each server. Then it will trigger the `./pbf-helper.sh` script on each server, this will update and deploy the docker setup found in the `docker-compose.yml.tmpl` for each server.

## To run
__Before__ you run `./pbf-engine.sh` this script, setup your __servers.details__ using the following format, and be place the file one directory up.

```text
ServerPass      ServerIP        WebbsiteDomain                  Username        Userpass
```
> example
```text
sdf2wew4dw	13.403.21.123	joomla1-us.pizza-bugs-fun.com	joomla1-us	joomla1-us
a258gsq33f	12.325.7.145	joomla2-us.pizza-bugs-fun.com	joomla2-us	joomla2-us
12fhj753da	134.42.23.23	joomla3-us.pizza-bugs-fun.com	joomla3-us	joomla3-us
```

### Then run
```bash
$ sudo chmod +x pbf-engine.sh
$ ./pbf-engine.sh
```

# Notice
This script will add our [public keys to your server](https://github.com/vdm-io/Joomla-Docker/blob/main/PBF2020/pbf-helper.sh#L36), make sure to remove those if you are trying to reuse this script.

```text
Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
Copyright (C) 2019. All Rights Reserved
GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
```
