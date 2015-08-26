#!/bin/sh

set -e

## vnet

_var_set () {

    MODEM=${1:-ZTE830FT}
    [ $MODEM == ZTE830FT ] && MODEM_IP='192.168.0.1'
}

set_mode () {

    MODEM_MODE=$1
    [ $MODEM_MODE == LOW  ] && [ $MODEM == ZTE830FT ] && MODEM_MODE='GSM_AND_LTE'
    [ $MODEM_MODE == HIGH ] && [ $MODEM == ZTE830FT ] && MODEM_MODE='Only_LTE'

    ## Modes for ZTE 830FT: GSM_AND_LTE, Only_LTE, NETWORK_auto, Only_GSM, Only_WCDMA, WCDMA_AND_GSM, WCDMA_AND_LTE.

    wget -O - --header "Referer: http://$MODEM_IP/index.html" --post-data "isTest=false&goformId=SET_BEARER_PREFERENCE&BearerPreference=$MODEM_MODE" http://$MODEM_IP/goform/goform_set_cmd_process 2>/dev/null | logger -s -t set_mode

}

_ussd_send () {

    USSD_COMMAND=$1
    wget -O - --header "Referer: http://$MODEM_IP/index.html" --post-data "isTest=false&goformId=USSD_PROCESS&USSD_operator=ussd_send&USSD_send_number=`echo $USSD_COMMAND | sed 's/\#/%23/'`&notCallback=true" http://$MODEM_IP/goform/goform_set_cmd_process 2>/dev/null | logger -s -t _ussd_send

}

ussd_send () {

    USSD_COMMAND=$1
    set_mode LOW
    echo "Please wait 20 seconds for modem to change the mode..."
    sleep 20
    _ussd_send $USSD_COMMAND
    echo "Please wait 20 seconds for modem to change the mode..."
    sleep 20
    set_mode HIGH
}

ussd_read () {
    TMP_USSD_FILE='/tmp/vnet_ussd_read'

    ## Pause some seconds is neccessary after USSD send and reply receiving
    wget -O - --header "Referer: http://$MODEM_IP/index.html" http://$MODEM_IP/goform/goform_get_cmd_process?cmd=ussd_data_info 2>/dev/null > $TMP_USSD_FILE
    USSD=`cat $TMP_USSD_FILE | cut -d '}' -f 1 | cut -d ':' -f 4 | sed 's/"//g'`
    printf $( echo "$USSD" | sed "s,\(..\),\\\\x\1,g" ) 2>/dev/null | iconv -f ucs-2be -t UTF-8

    ## One more way to decrypt - Perl is required
    #ussd=`cat /tmp/vnet_ussd.log`; echo \'+CUSD: 0,"$ussd",72\' |   perl -ne '@a = m/([0-9A-F]{4})/g; map { eval "print \"\\x{$_}\""; } @a;' 2>/dev/null

    rm $TMP_USSD_FILE

}

_sms_send () {

    SMS_NUMBER=`echo $1 | sed 's/\+/\%2B/'`
    SMS_CHARSET=$2
    SMS_MESSAGE=$3

    if [ $SMS_CHARSET == unicode ]
        then
            wget -O - --header "Referer: http://$MODEM_IP/index.html" --post-data "isTest=false&goformId=SEND_SMS&notCallback=true&Number=$SMS_NUMBER&sms_time=`date +%y%%3B%m%%3B%d%%3B%H%%3B%M%%3B%S%%3B%%2B6`&MessageBody=$SMS_MESSAGE&ID=-1&encode_type=UNICODE"      http://$MODEM_IP/goform/goform_set_cmd_process 2>/dev/null | logger -s -t sms_send
    else
            wget -O - --header "Referer: http://$MODEM_IP/index.html" --post-data "isTest=false&goformId=SEND_SMS&notCallback=true&Number=$SMS_NUMBER&sms_time=`date +%y%%3B%m%%3B%d%%3B%H%%3B%M%%3B%S%%3B%%2B6`&MessageBody=$SMS_MESSAGE&ID=-1&encode_type=GSM7_default" http://$MODEM_IP/goform/goform_set_cmd_process 2>/dev/null | logger -s -t sms_send
    fi
}

sms_send () {

    set_mode LOW   
    echo "Please wait 20 seconds for modem to change the mode..."                                                                                                                                              
    sleep 20 
    _sms_send $*
    echo "Please wait 20 seconds for modem to change the mode..."                                                                                                                                              
    sleep 20                                                                                                                                                                                                   
    set_mode HIGH 
}

sms_read_list () {

    SMS_COUNT=$1
    SMS_LIST=$2
    [ $SMS_LIST == received ]        && SMS_LIST=0
    [ $SMS_LIST == received_unread ] && SMS_LIST=1
    [ $SMS_LIST == sent ]            && SMS_LIST=2
    [ $SMS_LIST == failed ]          && SMS_LIST=3
    [ $SMS_LIST == all ]             && SMS_LIST=10
    TMP_SMS_FILE='/tmp/vnet_sms_read'
    ## tag=0 for received messages, tag=2 for sent ones, tag=3 for failed messages

    wget -O - --header "Referer: http://$MODEM_IP/index.html" --post-data "isTest=false&cmd=sms_data_total&page=0&data_per_page=500&mem_store=1&tags=$SMS_LIST&order_by=order+by+id+desc" http://$MODEM_IP/goform/goform_get_cmd_process 2>/dev/null > $TMP_SMS_FILE
    SMS_LIST=`cat $TMP_SMS_FILE | sed -e 's/{"messages":\[//g' -e 's/},/},\n/g' -e 's/",/", /g' -e 's/[{}]//g' | head -n $SMS_COUNT | awk '{print $3}' | awk -F ":" '{print $2}' | sed 's/[",]*//g'`

    for i in `seq $SMS_COUNT`
        do
            echo $i.`cat $TMP_SMS_FILE | sed -e 's/{"messages":\[//g' -e 's/},/},\n/g' -e 's/",/", /g' -e 's/[{}]//g' | head -n $i | tail -n 1 | awk '{print $1,$2,$4,$5,$7,$8,$9}'`
            SMS_MESSAGE=`echo $SMS_LIST | cut -d ' ' -f $i`
            printf $( echo $SMS_MESSAGE | sed "s,\(..\),\\\\x\1,g" ) 2>/dev/null | iconv -f ucs-2be -t UTF-8
            echo -e "\n\n"
        done

    rm "$TMP_SMS_FILE"
}

sms_read () {

    SMS_COUNT=$1
    SMS_LIST=$2
    [ $SMS_LIST == received ]        && SMS_LIST=0
    [ $SMS_LIST == received_unread ] && SMS_LIST=1
    [ $SMS_LIST == sent ]            && SMS_LIST=2
    [ $SMS_LIST == failed ]          && SMS_LIST=3
    [ $SMS_LIST == all ]             && SMS_LIST=10
    TMP_SMS_FILE='/tmp/vnet_sms_read'
    ## tag=0 for received messages, tag=2 for sent ones, tag=3 for failed messages

    wget -O - --header "Referer: http://$MODEM_IP/index.html" --post-data "isTest=false&cmd=sms_data_total&page=0&data_per_page=500&mem_store=1&tags=$SMS_LIST&order_by=order+by+id+desc" http://$MODEM_IP/goform/goform_get_cmd_process 2>/dev/null > $TMP_SMS_FILE
    SMS_LIST=`cat $TMP_SMS_FILE | sed -e 's/{"messages":\[//g' -e 's/},/},\n/g' -e 's/",/", /g' -e 's/[{}]//g' | head -n $SMS_COUNT | tail -n 1 | awk '{print $3}' | awk -F ":" '{print $2}' | sed 's/[",]*//g'`
    SMS_MESSAGE=`echo $SMS_LIST | cut -d ' ' -f $SMS_COUNT`
    printf $( echo $SMS_MESSAGE | sed "s,\(..\),\\\\x\1,g" ) 2>/dev/null | iconv -f ucs-2be -t UTF-8
    rm "$TMP_SMS_FILE"
}


set_sms_read () {

    SMS_IDS=`echo $1 | sed 's/,/%3B/g' | sed 's/$/%3B/'`
    SET_TAG=${2:-0}

    wget -O - --header "Referer: http://$MODEM_IP/index.html" --post-data "isTest=false&goformId=SET_MSG_READ&msg_id=$SMS_IDS&tag=$SET_TAG" http://$MODEM_IP/goform/goform_set_cmd_process 2>/dev/null

}


_var_set $*

[ `which iconv > /dev/null; echo $?` -ne 0 ] && echo "WARNING: To encrypt/decrypt messages \"iconv\" package must be installed"

case $2 in

    ussd_send)
        ussd_send $3
;;
    ussd_read)
        ussd_read
;;
    sms_send)
        sms_send $3 $4 $5
;;
    sms_read_list)
        sms_read_list $3 $4
;;
    sms_read)
        sms_read $3 $4
;;
    set_sms_read)
        set_sms_read $3 $4
;;
    set_mode)
        set_mode $3
;;
    *)
        echo "Usage: `basename $0` <modem_type> <command> <arg1> <arg2> <arg3>"
        echo
        echo "Where"
        echo "<modem_type>: ZTE830FT"
        echo "<command>: ussd_send, ussd_read, sms_send, sms_read_list, sms_read, set_sms_read, set_mode"
        echo "<arg1>: <ussd_command_to_send> (ex.*111#), <sms_number_to_send> (ex.+77085556677), <number_of_sms_to_read> for sms_read_list, <sms_numberto_read> for sms_read, <sms IDs to mark> (ex.5,6,7) for set_sms_read, <mode> (ex.Only_LTE) for set_mode"
        echo "<arg2>: <unicode> or <latin> for sms_send, <received> <received_unread> or <sent> or <failed> or <all> for sms_read_list and sms_read, <tag> (default is 0) for set_sms_read"
        echo "<arg3>: <encoded_sms_message_to_send>"
;;

esac




















































: <<'COMMENT2'

################################################################################
## This script is for SMS messages encoding in BASH.  On PC only. SHELL and Openwrt do not work - "prinf" command works incorrectly.

#!/bin/bash

## vnet

## Script encodes input string to UTF-16 (f.e. to send SMS)
## Works in BASH only

# File to read
INPUT=input.txt

# while loop
while IFS= read -r -N1 char
do
        # display one character at a time
        printf "%04X" \'"$char"
## if read from stdin
done

## If taken from file
#done < "$INPUT"

################################################################################

COMMENT2
