#!/bin/sh

if [ -f /mnt/dav/.notmounted ] ;then
 mount.davfs  https://cloud.ctph.com.ua/remote.php/webdav /mnt/dav
fi

if [ -f /mnt/dav/.notmounted ] ;then
 exit
fi

/usr/bin/find /mnt/dav/video -maxdepth 1 -type d -mtime +0 -exec rm -rf "{}" \;
