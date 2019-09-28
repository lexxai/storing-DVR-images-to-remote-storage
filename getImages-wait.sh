#!/bin/sh
securityhost=DVR.url
securityport=80
securityuser=dvradmin
securitypwd=dvrapwd

url_machine="http://${securityhost}:${securityport}/cgi-bin/nobody/Machine.cgi?action=get_capability"
url_smartm="http://${securityhost}:${securityport}/cgi-bin/guest/SmartMonitor.cgi"

#--------------------
function islive_pingdvr()
{
#test security device on live state.
ping ${securityhost}  -c 1 -W 2 > /dev/null 
if [ $? -gt 0 ];then
 echo host  ${securityhost} down.
 needwait=1
 sleep 5
else
 needwait=0
fi
}

function get_dvrmachine()
{
dvrmachine=$(curl -s \
   --max-time 1\
   -X GET ${url_machine} | head -n 2 | tail -n 1)
if [  -z "${dvrmachine}" ];then
  echo " error get machine , may be device frozen ?"
  sleep 5
  needwait=1
else
  needwait=0
fi
}



#------------------

needwait=0
while  true ; do
 echo Start ping... 
 islive_pingdvr
 if [ ${needwait} -eq 0 ];then
   get_dvrmachine
 fi
 if [ ${needwait} -eq 0 ];then
  break; 
 fi 
done

echo Start monitoring
while true; do
triggerd=0
triggered_ch=0
triggered_time=0
while read result; do
  #echo "READ: ${result}"
  remainder=$result
  first="${remainder%%=*}"; remainder="${remainder#*=}"
  second="${remainder%%=*}"; remainder="${remainder#*=}"
  case ${first} in
    "SmartMonitor") 
        #echo SM is $second
	      if [ "${second}" == "Start"  ];then
		      triggerd=1
	      fi
	      ;;
    "Channel") 
        #echo CH is $second
	      if [ ${triggerd} -eq 1 ];then
		      triggered_ch=$second
	      fi
	      ;;
    "Time") 
        #echo Time is $second
	      if [ ${triggerd} -eq 1 ];then
		      triggered_time=$(date  -D'%Y/%m/%d %H:%M:%S' -d "${second}" +%s)
	      fi
	      ;;
  esac
done << EOF
 $(curl -s \
   --list-only \
   --keepalive-time 30 \
   --max-time 0 \
   --ignore-content-length \
   --user ${securityuser}:${securitypwd} \
   -H "Content-Type: application/x-www-form-urlencoded" \
   -H "Connection: keep-alive" \
   --user-agent "AVTECH/1.0" \
   -X POST ${url_smartm} | egrep "^SmartMonitor=Start|^Channel=|^Time=")
EOF

# MAIN ENGINE AFTER EVENT
#echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ loop

if [ ${triggerd} -eq 1 ];then
 #echo Triggered ${triggered_ch} ${triggered_time}
 /root/getImg.sh  ${triggerd} ${triggered_ch} ${triggered_time} & >/dev/null
fi

done

