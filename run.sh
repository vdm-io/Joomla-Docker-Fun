#!/bin/bash
clear;

#██████████████████████████████████████████████████████████████████ COMMENTS ███
#
# Vast Development Method - Docker Container Builder (2019)
# Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>
# Copyright (C) 2019. All Rights Reserved
# GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#

# Docker 
command -v docker >/dev/null 2>&1 || { echo "Docker NOT installed. Aborting!"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose NOT installed. Aborting!"; exit 1; }

#█████████████████████████████████████████████████████████████ main function ███
function main() {
	# make sure config is set
	if [ ! -f "$PROPERTYFILE" ]
	then
		print "Config NOT found. Aborting!" F
		exit 1
	fi
print
print "█████████████████████████████████████████████████████████████████████████" H2
print "█                                                                       █" H2
print "█                         VDM - CONTAINER - BUILDER                     █" H2
print "█                                                                       █" H2
print "█████████████████████████████████████████████████████████████████████████" H2
print
print "█████████████████████████████████████████████ Vast Development Method ███" H2
print
print
	# show the configuration details at least once
	showConfig
	sleep 3 # pause to read
	# is this an active build/pull of this image
	if [ "$ACTIVEPHP" -eq "1" ]; then
    # Always first setup the PHP local image
    setupPHPimage
	fi
	# is this an active build/pull of this image
	if [ "$ACTIVEJOOMLA" -eq "1" ]; then
    # setup Joomla docker image
    setupJOOMLAimage
	fi
	# deploy the Joomla containers
	deployJoomlaContainer
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
    elif [ "$2" == "B" ]; then
        echo -e "${normblue}$1${NC}"
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
# Docker Details
ACTIVEPHP=$(getProperty "docker.php")
ACTIVEJOOMLA=$(getProperty "docker.joomla")
# Website Details
DOMAIN=$(getProperty "container.website.domain")
WEBSITESUNAME=$(getProperty "container.website.uname")
WEBSITESUSERNAME=$(getProperty "container.website.username")
WEBSITESEMAIL=$(getProperty "container.website.email")
WEBSITESNAME=$(getProperty "container.website.websitename")
WEBSITESUSERPASS=$(getProperty "container.website.websiteuserpass")
DBDRIVER=$(getProperty "container.website.dbdriver")
DBHOST=$(getProperty "container.website.dbhost")
DBUSER=$(getProperty "container.website.dbuser")
DBPASS=$(getProperty "container.website.dbpass")
DBRPASS=$(getProperty "container.website.dbrootpass")
DBNAME=$(getProperty "container.website.dbname")
DBPREFIX=$(getProperty "container.website.dbprefix")
SMTPHOST=$(getProperty "container.website.smtphost")
# Joomla image name
joomlaImagePull=$(getProperty "joomla.image.pull") # default should be 1
joomlaImageFolder=$(getProperty "joomla.image.docker.folder") # default "JOOMLA4.0.0-beta4"
joomlaImageName=$(getProperty "joomla.image.docker.name") # default "vdmio/joomla"
joomlaImageTag=$(getProperty "joomla.image.docker.tag.name") # default "4.0.0-beta4"
# is this an active build/pull of this image
if [ "$ACTIVEPHP" -eq "1" ]; then
  # PHP image name
  phpImagePull=$(getProperty "php.image.pull") # default should be 1
  phpImageFolder=$(getProperty "php.image.docker.folder") # default "PHP7.4"
  phpImageName=$(getProperty "php.image.docker.name") # default "vdmio/php"
  phpImageTag=$(getProperty "php.image.docker.tag.name") # default "7.4-apache-node12"
fi

function showConfig(){
print
print "█████████████████████████████████████████████████████████ SHOW CONFIG ███" H1
print
print "CONTAINER DETAILS" H1
print "DOMAIN:                            $DOMAIN" O
print "WEBSITESNAME:                      $WEBSITESNAME" O
print "WEBSITESUNAME:                     $WEBSITESUNAME" O
print "WEBSITESUSERNAME:                  $WEBSITESUSERNAME" O
print "WEBSITESUSERPASS                   xxxxxxxxxxxxxxxxxx" O
print "WEBSITESEMAIL:                     $WEBSITESEMAIL" O
print "DBDRIVER:                          $DBDRIVER" O
print "DBHOST:                            $DBHOST" O
print "DBUSER:                            $DBUSER" O
print "DBPASS:                            xxxxxxxxxxxxxxxxxx" O
print "DBRPASS:                           xxxxxxxxxxxxxxxxxx" O
print "DBNAME:                            $DBNAME" O
print "DBPREFIX:                          $DBPREFIX" O
print "SMTPHOST:                          $SMTPHOST" O
print
# is this an active build/pull of this image
if [ "$ACTIVEPHP" -eq "1" ]; then
print "PHP IMAGE DETAILS" H1
print "phpImagePull:                      $phpImagePull" O
print "phpImageFolder:                    $phpImageFolder" O
print "phpImageName:                      $phpImageName" O
print "phpImageTag:                       $phpImageTag" O
print
fi
# is this an active build/pull of this image
if [ "$ACTIVEJOOMLA" -eq "1" ]; then
print "JOOMLA IMAGE DETAILS" H1
print "joomlaImagePull:                   $joomlaImagePull" O
print "joomlaImageFolder:                 $joomlaImageFolder" O
print "joomlaImageName:                   $joomlaImageName" O
print "joomlaImageTag:                    $joomlaImageTag" O
print
fi
print
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
	elif [ ! "$(docker images | grep "$phpImageName")" ]; then
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
function setupJOOMLAimage() {
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
	elif [ ! "$(docker images | grep "$joomlaImageName")" ]; then
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

#████████████████████████████████████████████████████ Setup Joomla Container ███
function deployJoomlaContainer() {
print
print
print "████████████████████████████████████████████ DEPLOY JOOMLA CONTAINER ███" H1
print
print
    # make sure our docker folder is created
		if [ ! -d "$DOCKERFOLDER" ]; then
			mkdir "$DOCKERFOLDER"
		fi
    # Setup docker compose file
    print "Moving docker-compose.yml into place" B
    cp "$PWD/${joomlaImageFolder}/docker-compose.yml.tmpl" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DOMAIN} value with $DOMAIN" B
    sed -i "s/{DOMAIN}/$DOMAIN/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {WEBSITESUNAME} value with $WEBSITESUNAME" B
    sed -i "s/{WEBSITESUNAME}/$WEBSITESUNAME/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {WEBSITESUSERNAME} value with $WEBSITESUSERNAME" B
    sed -i "s/{WEBSITESUSERNAME}/$WEBSITESUSERNAME/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {WEBSITESUSERPASS} value with xxxxxxxxxxxxxxxxxx" B
    sed -i "s/{WEBSITESUSERPASS}/$WEBSITESUSERPASS/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {WEBSITESEMAIL} value with $WEBSITESEMAIL" B
    sed -i "s/{WEBSITESEMAIL}/$WEBSITESEMAIL/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {WEBSITESNAME} value with $WEBSITESNAME" B
    sed -i "s/{WEBSITESNAME}/$WEBSITESNAME/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DBDRIVER} value with $DBDRIVER" B
    sed -i "s/{DBDRIVER}/$DBDRIVER/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DBHOST} value with $DBHOST" B
    sed -i "s/{DBHOST}/$DBHOST/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DBUSER} value with $DBUSER" B
    sed -i "s/{DBUSER}/$DBUSER/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DBPASS} value with xxxxxxxxxxxxxxxxxx" B
    sed -i "s/{DBPASS}/$DBPASS/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DBRPASS} value with xxxxxxxxxxxxxxxxxx" B
    sed -i "s/{DBRPASS}/$DBRPASS/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DBNAME} value with $DBNAME" B
    sed -i "s/{DBNAME}/$DBNAME/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {DBPREFIX} value with $DBPREFIX" B
    sed -i "s/{DBPREFIX}/$DBPREFIX/g" "${DOCKERFOLDER}/docker-compose.yml"
    print "Updating the {SMTPHOST} value with $SMTPHOST" B
    sed -i "s/{SMTPHOST}/$SMTPHOST/g" "${DOCKERFOLDER}/docker-compose.yml"
    # Run docker compose
    docker-compose -f "${DOCKERFOLDER}/docker-compose.yml" up -d
print
print
print "████████████████████████████████████████ CONTAINER HAS BEEN DEPLOYED ███" H1
print
}

# run program
main
