#!/bin/bash
clear;

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Docker Containers Builder (2019)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2019. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

# Docker 
command -v docker >/dev/null 2>&1 || { echo "Docker NOT installed. Aborting!"; exit 1; }


#█████████████████████████████████████████████████████████████ main function ███
function main() {
	# make sure config is set
	if [ ! -f $PROPERTYFILE ]
	then
		print "Config NOT found. Aborting!" F
		exit 1
	fi
print
print "█████████████████████████████████████████████████████████████████████████" H2
print "█                                                                       █" H2
print "█                        VDM - CONTAINERS - BUILDER                     █" H2
print "█                                                                       █" H2
print "█████████████████████████████████████████████████████████████████████████" H2
print
print "█████████████████████████████████████████████ Vast Development Method ███" H2
print
print
	# show the configuration details at least once
	showConfig
	sleep 3 # pause to read
	# exit 1 # to debug
	# setup Traefik
	setupTraefik
	# setup Portainer
	setupPortainer
	# setup website config details
	setupWebConfig
	# Always first setup the PHP local image
	setupPHPimage
	# setup joomla docker image
	setupJOOMLABASEimage
	# build all websites
	print "Next We Setup the docker-compose file per website, and... well we are nearly there." O
print
print
print "█████████████████████████████████████████████████████████████████████████" H2
print "█                                                                       █" H2
print "█                        VDM - CONTAINERS - DONE                        █" H2
print "█                                                                       █" H2
print "█████████████████████████████████████████████████████████████████████████" H2
print
print

}


#█████████████████████████████████████████████████████████████████ help menu ███
function show_help {
cat << EOF
=============================================
Usage: ./deploy.sh [OPTION...]
 To Create a bulk number of websites

   -f Path to config file
   -h Print this Help

=============================================
EOF
exit 1
}

#█████████████████████████████████████████████████████████████████ VARIABLES ███

### Color Codes ###
normblack="\033[0;30m"; 
normblue="\033[0;34m"; 
normgreen="\033[0;32m"; 
normnormcyan="\033[0;36m"; 
normRed="\033[0;31m"; 
normpurple="\033[0;35m"; 
normorange="\033[0;33m"; 
normyellow="\033[1;33m"; 
normwhite="\033[1;37m"; 
lightGray="\033[0;37m";     
lightBlue="\033[1;34m"; 
lightGreen="\033[1;32m"; 
lightCyan="\033[1;36m"; 
lightRed="\033[1;31m"; 
lightPurple="\033[1;35m"; 
darkGray="\033[1;30m";     
NC="\033[0m";

#██████████████████████████████████████████████████████████ Function - PRINT ███
function print {
    if [ -z "$2" ]; then
        echo -e ""
    elif [ "$2" == "I" ]; then
        echo -e "${lightGray}$1${NC}"
    elif [ "$2" == "S" ]; then
        echo -e "${lightGreen}$1${NC}"
    elif [ "$2" == "F" ]; then
        echo -e "${lightRed}$1${NC}"
    elif [ "$2" == "H1" ]; then
        echo -e "${lightCyan}$1${NC}"
    elif [ "$2" == "H2" ]; then
        echo -e "${lightBlue}$1${NC}"
    elif [ "$2" == "O" ]; then
        echo -e "${normorange}$1${NC}"
    fi
}

#███████████████████████████████████████████████████ Function - GET PROPERTY ███
function getProperty {
	if [ -f $PROPERTYFILE ]
	then
		PROP_KEY=$1
		PROP_VALUE=`cat $PROPERTYFILE | grep "$PROP_KEY" | cut -d'=' -f2`
		echo $PROP_VALUE
	fi
}

#█████████████████████████████████████████████████████████████████ get Input ███
# main config folder
DOCKERFOLDER=$PWD/docker
# the main config file
PROPERTYFILE="$DOCKERFOLDER/config.properties" # or get from -f command
# getopts howtos: (mainly for me)
# http://www.theunixschool.com/2012/08/getopts-how-to-pass-command-line-options-shell-script-Linux.html
# http://mywiki.wooledge.org/BashFAQ/035
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":f:" opt; do
	case $opt in
	f)
		PROPERTYFILE=$OPTARG
	;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		echo
		show_help
	;;
	*)
		echo "Invalid option: -$OPTARG" >&2
		echo
		show_help
	;;
	esac
done

#█████████████████████████████████████████████████████████████ Config values ███
# number of websites to build
WEBSITESNUMBER=$(getProperty "container.website.number")
WEBSITESUNAME=$(getProperty "container.website.uname")
WEBSITESUSERNAME=$(getProperty "container.website.username")
WEBSITESEMAIL=$(getProperty "container.website.email")
WEBSITESNAME=$(getProperty "container.website.websitename")
# 1 = true and 0 = false
PORTAINER=$(getProperty "portainer.activate") # default should be 1
PORTAINERNAME=$(getProperty "portainer.name") # default "portainer"
TRAEFIK=$(getProperty "traefik.activate") # default should be 1
TRAEFIKNAME=$(getProperty "traefik.name") # default "traefik"
TRAEFIKDOMAIN=$(getProperty "traefik.domain") # default "vdm.io"
TRAEFIKEMAIL=$(getProperty "traefik.email") # default "your@email.com"
TRAEFIKDASHBOARD=$(getProperty "traefik.dashboard") # default "true"
TRAEFIKINSECURE=$(getProperty "traefik.insecure") # default "true"
# PHP image name
phpImagePull=$(getProperty "php.image.pull") # default should be 1
phpImageFolder=$(getProperty "php.image.docker.folder") # default "PHP7.4"
phpImageName=$(getProperty "php.image.docker.name") # default "vdmio/php"
phpImageTag=$(getProperty "php.image.docker.tag.name") # default "7.4-apache-node12"
# Joomla image name
joomlaImagePull=$(getProperty "joomla.image.pull") # default should be 1
joomlaImageFolder=$(getProperty "joomla.image.docker.folder") # default "JOOMLA4.0.0-beta4"
joomlaImageName=$(getProperty "joomla.image.docker.name") # default "vdmio/joomla"
joomlaImageTag=$(getProperty "joomla.image.docker.tag.name") # default "4.0.0-beta4"

function showConfig(){
print
print "█████████████████████████████████████████████████████████ SHOW CONFIG ███" H1
print
print "CONTAINER DETAILS" H1
print "WEBSITESNUMBER:                    $WEBSITESNUMBER" O
print "WEBSITESUNAME:                     $WEBSITESUNAME" O
print "WEBSITESUSERNAME:                  $WEBSITESUSERNAME" O
print "WEBSITESEMAIL:                     $WEBSITESEMAIL" O
print "WEBSITESNAME:                      $WEBSITESNAME" O
print
print "PORTAINER DETAILS" H1
print "PORTAINER:                         $PORTAINER" O
print "PORTAINERNAME:                     $PORTAINERNAME" O
print
print "TRAEFIK DETAILS" H1
print "TRAEFIK:                           $TRAEFIK" O
print "TRAEFIKNAME:                       $TRAEFIKNAME" O
print "TRAEFIKDOMAIN:                     $TRAEFIKDOMAIN" O
print "TRAEFIKEMAIL:                      $TRAEFIKEMAIL" O
print "TRAEFIKDASHBOARD:                  $TRAEFIKDASHBOARD" O
print "TRAEFIKINSECURE:                   $TRAEFIKINSECURE" O
print
print "PHP IMAGE DETAILS" H1
print "phpImagePull:                      $phpImagePull" O
print "phpImageFolder:                    $phpImageFolder" O
print "phpImageName:                      $phpImageName" O
print "phpImageTag:                       $phpImageTag" O
print
print "JOOMLA IMAGE DETAILS" H1
print "joomlaImagePull:                   $joomlaImagePull" O
print "joomlaImageFolder:                 $joomlaImageFolder" O
print "joomlaImageName:                   $joomlaImageName" O
print "joomlaImageTag:                    $joomlaImageTag" O
print
print
}


#███████████████████████████████████████████████████████████ Little Repeater ███
function repeat() {
	head -c $1 </dev/zero | tr '\0' $2
}


#████████████████████████████████████████████████████████████████ ECHO Tweak ███
function echoTweak() {
	echoMessage="$1"
	mainlen="$2"
	characters="$3"
	if [ $# -lt 2 ]; then
		mainlen=60
	fi
	if [ $# -lt 3 ]; then
		characters='\056'
	fi
	chrlen="${#echoMessage}"
	increaseBy=$((mainlen - chrlen))
	tweaked=$(repeat "$increaseBy" "$characters")
	echo -n "$echoMessage$tweaked"
}

#█████████████████████████████████████████████████████ Setup PHP local image ███
function setupPHPimage() {
	# should we pull the image or build the image
	if [ "$phpImagePull" -eq "1" ]; then
print
print
print "██████████████████████████████████████████████████████ PULL PHP IMAGE ███" H1
print
print	
		docker pull "$phpImageName:$phpImageTag"	
print
print
print "██████████████████████████████████████████████ DONE PULLING PHP IMAGE ███" H1
print
print	
	# only setup PHP if not already done
	elif [ ! "$(docker images | grep $phpImageName)" ]; then
print
print
print "█████████████████████████████████████████████████████ BUILD PHP IMAGE ███" H1
print
print
		docker build $(dirname $0)/$phpImageFolder -t "$phpImageName:$phpImageTag"
print
print
print "█████████████████████████████████████████████ DONE BUILDING PHP IMAGE ███" H1
print
print
	fi
}

#██████████████████████████████████████████████████ Setup Joomla local image ███
function setupJOOMLABASEimage() {
	# should we pull the image or build the image
	if [ "$joomlaImagePull" -eq "1" ]; then
print
print
print "███████████████████████████████████████████████████ PULL JOOMLA IMAGE ███" H1
print
print	
		docker pull "$joomlaImageName:$joomlaImageTag"	
print
print
print "███████████████████████████████████████████ DONE PULLING JOOMLA IMAGE ███" H1
print
print	
	# only setup Joomla if not already done
	elif [ ! "$(docker images | grep $joomlaImageName)" ]; then
print
print
print "██████████████████████████████████████████████████ BUILD JOOMLA IMAGE ███" H1
print
print
		docker build $(dirname $0)/$joomlaImageFolder -t "$joomlaImageName:$joomlaImageTag"
print
print
print "██████████████████████████████████████████ DONE BUILDING JOOMLA IMAGE ███" H1
print
print
	fi
}

#██████████████████████████████████████████████ Setup Random Website details ███
function setupWebConfig() {
	# first we create the text file of all the website details, if not already created.
	# you can add your own manual list of website details (tab delimiter)
	# subdomain	websitename	username	password	email	name
	websiteConfigPath="${DOCKERFOLDER}/websites.txt"
	if [ ! -f "$websiteConfigPath" ] 
	then
print
print
print "████████████████████████████████████████ Building Website Config File ███" H1
print
print
		echoTweak "Building config file for $WEBSITESNUMBER websites."
		if [ ! -d "$DOCKERFOLDER" ]; then
			mkdir "$DOCKERFOLDER"
		fi
		# create the cofig file
		touch "$websiteConfigPath"
		# we set the subdomain username password
		for i in $(seq $WEBSITESNUMBER)
		do
			password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1);
			subdomain=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 7 | head -n 1);
			# set the date to the website config
			echo -e "${subdomain}\t" \
				"${WEBSITESNAME}\t" \
				"${WEBSITESUSERNAME}\t" \
				"${password}\t" \
				"${WEBSITESEMAIL}" \
				"${WEBSITESUNAME}" \
				>> "$websiteConfigPath"
		done
		echo "Done!"
	fi
}

#█████████████████████████████████████████████████████████████ Setup Traefik ███
function setupTraefik() {
	# Check if we are using Traefik
	if [ "$TRAEFIK" -eq "1" ]; then
		# only install if Traefik is not already setup
		if [ ! "$(docker ps -a | grep $TRAEFIKNAME)" ]; then
print
print
print "███████████████████████████████████████████████████████ SETUP TRAEFIK ███" H1
print
print
			# Setup configuration file
			cp $PWD/scripts/traefik.yml.tmpl "${DOCKERFOLDER}/traefik.yml"
			sed -i "s/{DOMAIN}/$TRAEFIKDOMAIN/g" "${DOCKERFOLDER}/traefik.yml"
			sed -i "s/{EMAIL}/$TRAEFIKEMAIL/g" "${DOCKERFOLDER}/traefik.yml"
			sed -i "s/{DASHBOARD}/$TRAEFIKDASHBOARD/g" "${DOCKERFOLDER}/traefik.yml"
			sed -i "s/{INSECURE}/$TRAEFIKINSECURE/g" "${DOCKERFOLDER}/traefik.yml"
			# Run docker
			docker run -d -p 8080:8080 -p 80:80 -p 443:443 \
			-v $DOCKERFOLDER/traefik.yml:/etc/traefik/traefik.yml \
			-v /var/run/docker.sock:/var/run/docker.sock \
			--name=$TRAEFIKNAME --restart=always \
			traefik:v2.3
print
print
print "███████████████████████████████████████████████████████ TRAEFIK READY ███" H1
print
		fi
	fi
}

#███████████████████████████████████████████████████████████ Setup Portainer ███
function setupPortainer() {
	# Check if we are using Protainer
	if [ "$PORTAINER" -eq "1" ]; then
		# only install if Portainer is not already setup
		if [ ! "$(docker ps -a | grep $PORTAINERNAME)" ]; then
print
print
print "█████████████████████████████████████████████████████ SETUP Portainer ███" H1
print
print
			docker volume create portainer_data
			docker run -d -p 8000:8000 -p 9000:9000 \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v portainer_data:/data \
			--name=$PORTAINERNAME --restart=always \
			portainer/portainer-ce
print
print
print "████████████████████████████████████████████████████ Portainer READY ███" H1
print
		fi
	fi
}

# run program
main
