#!/bin/sh
if [ -z "$1" ];then
 echo need parameters, exit
 exit 
fi

securityhost=DVR.url
securityport=80
securityuser=dvradmin
securitypwd=dvrapwd

url_media="http://${securityhost}:${securityport}/cgi-bin/guest/Video.cgi?media=JPEG&resolution=4CIF"
url_machine="http://${securityhost}:${securityport}/cgi-bin/nobody/Machine.cgi?action=get_capability"
url_smartm="http://${securityhost}:${securityport}/cgi-bin/guest/SmartMonitor.cgi"

triggerd=$1
triggered_ch=$2
triggered_time=$3

moving_delay=12
deltatime=0

# LIB -----------------------------------

function get_dvrmachine()
{
dvrmachine=$(curl -s \
   --max-time 1\
   -X GET ${url_machine} | head -n 2 | tail -n 1)
if [  -z "${dvrmachine}" ];then
  echo " error get machine , may be device frozen ?"
  exit
fi
}

#--------------------
function islive_pingdvr()
{
#test security device on live state 
ping ${securityhost}  -c 1 -W 2 > /dev/null ; 
if [ $? -gt 0 ];then
 echo host  ${securityhost} down 
 exit
fi
}

#--------------------
function check_mounted()
{
if [ -f /mnt/dav/.notmounted ] ;then
 echo "/mnt/dav umounted, exit"
 exit
fi
}

#--------------------
function check_remotefilesystem()
{
#check mouning remote file system
if [ -f /mnt/dav/.notmounted ] ;then
 echo not mounted, try mount
 /usr/sbin/mount.davfs -o noexec https://cloud.ctph.com.ua/remote.php/webdav /mnt/dav
fi
check_mounted
}

#--------------------
function check_remotefilesystem_video()
{
if [ ! -d /mnt/dav/video ] ;then
 echo "/mnt/dav/video umounted, exit"
 /usr/sbin/umount.davfs /mnt/dav/
 kill $(cat /var/run/mount.davfs/mnt-dav.pid)
 rm /var/run/mount.davfs/mnt-dav.pid
 rm -r /tmp/davfs2/*
 exit
fi
}

#--------------------
function make_folders()
{
mdate=$(date '+%Y-%m-%d')
mhdate=$(date '+%Y-%m-%d-%H')
odir=/mnt/dav/video/${mdate}/${mhdate}

if [ ! -d ${odir} ] ;then
 mkdir -p ${odir}
fi
}

#--------------------
function loging()
{
  echo ${cdate}: ${get_motion_output} >> /root/getvideo.log
}

#--------------------
function get_image()
{
  cdate=$(date '+%Y-%m-%d-%H%M%S')
#  loging
  suff="-${triggered_time}-${triggered_ch}"
  fname="${cdate}${suff}.jpg"
#  echo $fname
  wget -q -T 6 \
    -O ${fname}  \
    -P ${odir} \
    --user=${securityuser} \
    --password=${securitypwd} \
    ${url_media}
}

# MAIN ----------------------------------

#islive_pingdvr
#get_dvrmachine
check_remotefilesystem
make_folders
check_remotefilesystem_video

if [ ${triggerd} -eq 1 ];then
 #echo Triggered ${triggered_ch} ${triggered_time}
 ltime=$(date '+%s')
 until [ ! $(($(date '+%s')-${ltime})) -le ${moving_delay} ] ; do
  #echo try load image `date`
  check_mounted
  get_image
  #sleep 5 
done
fi


