#!/bin/sh -x

## vnet

MODEM_IP='192.168.0.1'

wget -O /var/log/vnet_result.log --header "Referer: http://$MODEM_IP/index.html" --post-data 'isTest=false&goformId=SET_BEARER_PREFERENCE&BearerPreference=GSM_AND_LTE' http://$MODEM_IP/goform/goform_set_cmd_process
cat /var/log/vnet_result.log

sleep 20

wget -O /var/log/vnet_result.log --header "Referer: http://$MODEM_IP/index.html" --post-data 'isTest=false&goformId=USSD_PROCESS&USSD_operator=ussd_send&USSD_send_number=*838*11%23&notCallback=true' http://$MODEM_IP/goform/goform_set_cmd_process
cat /var/log/vnet_result.log

sleep 20

wget -O /var/log/vnet_result.log --header "Referer: http://$MODEM_IP/index.html" --post-data 'isTest=false&goformId=SET_BEARER_PREFERENCE&BearerPreference=Only_LTE' http://$MODEM_IP/goform/goform_set_cmd_process
cat /var/log/vnet_result.log
