#!/bin/sh

## vnet

SMS_FILE='/tmp/vnet_sms.txt'

## tag=0 for received messages, tag=2 for sent ones

wget -O $SMS_FILE --header "Referer: http://192.168.0.1/index.html" --post-data 'isTest=false&cmd=sms_data_total&page=0&data_per_page=500&mem_store=1&tags=0&order_by=order+by+id+desc' http://192.168.0.1/goform/goform_get_cmd_process
#SMS=`cat $SMS_FILE | sed -e 's/{"messages":\[//g' -e 's/},/},\n/g' -e 's/",/", /g' -e 's/[{}]//g' | awk '{print $3}' | head -n 1`
SMS=`cat $SMS_FILE | sed -e 's/{"messages":\[//g' -e 's/},/},\n/g' -e 's/",/", /g' -e 's/[{}]//g' | head -n 1 | awk '{print $3}' | awk -F ":" '{print $2}' | sed 's/[",]*//g'`
echo $SMS
printf $( echo "$SMS" | sed "s,\(..\),\\\\x\1,g" ) | iconv -f ucs-2be -t UTF-8
