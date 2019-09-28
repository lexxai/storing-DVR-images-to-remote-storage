#!/bin/sh

securityhost=DVR.url
securityport=80
securityuser=dvradmin
securitypwd=dvrapwd

url_time="http://${securityhost}:${securityport}/cgi-bin/supervisor/Time.cgi?action=sync"

#test security device on live state.
ping ${securityhost}  -c 1 -W 2 > /dev/null
if [ $? -gt 0 ];then
 echo host  ${securityhost} down.
 exit
fi

#detect deviation drv time from sytstem time
systeime=$(date +%s)
dvrtime=$(curl -s \
   --max-time 1\
   --ignore-content-length \
   --user ${securityuser}:${securitypwd} \
   -H "Content-Type: application/x-www-form-urlencoded" \
   --user-agent "AVTECH/1.0" \
   -X GET ${url_time} | tail -n +1)
if [  -z "${dvrtime}" ];then
  echo " error get time ${dvrtime}, may bedevice frozen ?"
  exit
fi
echo ${dvrtime}
