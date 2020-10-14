FROM vdmio/joomla:4.0.0-beta4

MAINTAINER Llewellyn van der Merwe <llewellyn.van-der-merwe@community.joomla.org>

# Website User Details
ENV WEBSITESUNAME=method \
    WEBSITESUSERNAME=Method \
    WEBSITESUSERPASS=vastdevelopmentmethod \
    WEBSITESEMAIL="your@email.com" \
# Website details
    WEBSITESNAME="Vast Development Method" \
# Website database details
    DBDRIVER=mysqli \
    DBHOST=mysql \
    DBUSER=root \
    DBPASS=root \
    DBNAME=joomla \
    DBPREFIX=vdm \
# Website email details
    SMTPHOST=mailcatcher
# load setup script
COPY docker-entrypoint.sh /home/docker/scripts/entrypoint.sh

ENTRYPOINT ["/home/docker/scripts/entrypoint.sh"]
CMD ["%%CMD%%"]
