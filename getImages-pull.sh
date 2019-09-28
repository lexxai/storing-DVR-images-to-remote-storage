#!/bin/sh
#exit()
securityhost=DVR.url
securityport=80
securityuser=dvradmin
securitypwd=dvrapwd

url_media="http://${securityhost}:${securityport}/cgi-bin/guest/Video.cgi?media=JPEG&resolution=4CIF"
url_time="http://${securityhost}:${securityport}/cgi-bin/supervisor/Time.cgi?action=get"
url_motion="http://${securityhost}:${securityport}/cgi-bin/supervisor/NetworkBk.cgi"
url_machine="http://${securityhost}:${securityport}/cgi-bin/nobody/Machine.cgi?action=get_capability"

path_ch1="/root/video_ch1.txt"
path_ch2="/root/video_ch2.txt"
moving_delay=60
deltatime=0

# LIB -----------------------------------

#------------------
function get_motion()
{
get_motion_output=""
lasttime_ch1=0
lasttime_ch2=0
triggered_ch1=0
triggered_ch2=0

if [ -f ${path_ch1} ];then
 lasttime_ch1=$(cat ${path_ch1})
fi
if [ -f ${path_ch2} ];then
 lasttime_ch2=$(cat ${path_ch2})
fi
triggered=0
while read action ch sdate stime; do
 #echo action[${action}]
 if [ "${action}" == "MOTION" ];then
    sec=$(date  -D'%Y/%m/%d %H:%M:%S' -d "${sdate} ${stime}" +%s)
    case ${ch} in
     1) if [ ${sec} -gt ${lasttime_ch1} ];then
         lasttime_ch1=$sec
	 triggered_ch1=1
	 triggered=1
	 #echo one1
        fi
	;;
     2) if [ ${sec} -gt ${lasttime_ch2} ];then
         lasttime_ch2=$sec
	 triggered_ch2=1
	 triggered=1
         #echo one2
        fi
	;;
    esac
    #echo ${ch} ${sdate} ${stime} this ${sec}
 fi
done << EOF
$(curl -s \
   --max-time 2 \
   --ignore-content-length \
   --user ${securityuser}:${securitypwd} \
   --data "action=query&type=search_list&command=latest&list_type=MOTION&hdd_num=255&list_num=5" \
   -H "Content-Type: application/x-www-form-urlencoded" \
   --user-agent "AVTECH/1.0" \
   -X POST ${url_motion} | tail -n +3)
EOF


if [ ${triggered_ch1} -gt 0 ];then
  get_motion_output="moving on ch1 ${lasttime_ch1} "
  echo ${lasttime_ch1} > ${path_ch1}
fi
if [ ${triggered_ch2} -gt 0 ];then
  get_motion_output="moving on ch2 ${lasttime_ch2}"
  echo ${lasttime_ch2} > ${path_ch2}
fi

if  [ ${triggered} -gt 0 ] ;then
  return 3
fi

dvrsec=$(date +%s)
delta=$((${dvrsec}-${lasttime_ch1}))
#delta=$((${delta}+${deltatime}))
if [ ${delta} -lt ${moving_delay} ];then
 get_motion_output="moving delay on ch1"
 return 3
fi
delta=$((${dvrsec}-${lasttime_ch2}))
#delta=$((${delta}+${deltatime}))
if [ ${delta} -lt ${moving_delay} ];then
 get_motion_output="moving delay on ch2"
 return 3
fi 

return 0
}
#--------------------

function get_dvrtimedeviation()
{
#detect deviation drv time from sytstem time
systeime=$(date +%s)
dvrtime=$(curl -s \
   --max-time 1\
   --ignore-content-length \
   --user ${securityuser}:${securitypwd} \
   -H "Content-Type: application/x-www-form-urlencoded" \
   --user-agent "AVTECH/1.0" \
   -X GET ${url_time} | tail -n +3)
if [  -z "${dvrtime}" ];then
  echo " error get time ${dvrtime}, may be device frozen ?"
  exit
fi
dvrsec=$(date  -D'%Y/%m/%d %a %H:%M:%S' -d "${dvrtime}" +%s)
if [  -z "${dvrsec}" ];then
  echo " error convert time ${dvrsec}"
  exit
fi
deltatime=$((${dvrsec}-${systeime}))
}

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
  loging
wget -q -T 6 \
 -O ${cdate}.jpg \
 -P ${odir} \
 --user=${securityuser} \
 --password=${securitypwd} \
 ${url_media}
}

# MAIN ----------------------------------

islive_pingdvr
get_dvrmachine

#get_dvrtimedeviation
check_remotefilesystem
make_folders
check_remotefilesystem_video

#MAIN LOOP

ltime=$(date '+%s')
until [ ! $(($(date '+%s')-${ltime})) -le 59 ] ; do
 get_motion
 mst=$?
 if [ ${mst} == 2 ];then
  break;
 fi
 if [ ${mst} == 3  ];then
  check_mounted
  get_image
  sleep 1
 else
  sleep 3
 fi
done
