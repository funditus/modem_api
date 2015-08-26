#!/bin/sh -x

## vnet

## Pause some seconds is neccessary after USSD send and reply receiving
wget -O /tmp/vnet_ussd.log http://192.168.0.1/goform/goform_get_cmd_process?cmd=ussd_data_info 2>/dev/null

USSD=`cat /tmp/vnet_ussd.log | cut -d '}' -f 1 | cut -d ':' -f 4 | sed 's/"//g'`

echo $USSD
printf $( echo "$USSD" | sed "s,\(..\),\\\\x\1,g" ) | iconv -f ucs-2be -t UTF-8

## One more way to decrypt - Perl is required
#ussd=`cat /tmp/vnet_ussd.log`; echo \'+CUSD: 0,"$ussd",72\' |   perl -ne '@a = m/([0-9A-F]{4})/g; map { eval "print \"\\x{$_}\""; } @a;' 2>/dev/null
