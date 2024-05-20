#!/bin/bash
#/home/crawl-dev/dgamelaunch-config/utils/provision-chroot.sh
source "$DGL_CONF_HOME/dgl-manage.conf"
/home/crawl-dev/dgamelaunch-config/bin/dgl create-versions-db
/home/crawl-dev/dgamelaunch-config/bin/dgl create-crawl-gamedir
/home/crawl-dev/dgamelaunch-config/bin/dgl publish --confirm

if [ "$1" = '--provision-chroot' ]; then
    /install-crawl-versions.sh
fi

if [ "$1" = '--provision-single' ]; then
    cp -a -n $DGL_CHROOT/crawl-master/crawl-git $DGL_CHROOT/crawl-master/crawl-$2
    /home/crawl-dev/dgamelaunch-config/bin/dgl update-trunk
    /home/crawl-dev/dgamelaunch-config/bin/dgl update-gcc $2 $3 
fi

/enable-apache.sh

/setup-cron.sh

/etc/init.d/ssh start
rm "$CHROOT_WEBDIR/run/webtiles.pid" #in case the container was stopped without cleaning up pid file in volume
/etc/init.d/webtiles restart
# would probably be more docker-ish if webtiles were running in the foreground
# for this case...
if [ "$1" = '--background' ]; then
    sleep infinity # gnu-specific trick
    exit 0
fi


# convenience: run whatever CL arguments there are if we got to this point.
# probably something like /bin/bash.
if [ ! -z $@ ]; then
    exec "$@"
fi

#Otherwise just tail the webtiles log
# if you get an error, that's because the trunk version is not installed in the volumes
# this means you should either use docker-entrypoint-build-trunk.sh
# or docker-entrypoint-build-all.sh as entrypoint to build crawl data into volumes 
tail -f $DGL_CHROOT/crawl-master/webserver/run/webtiles.log