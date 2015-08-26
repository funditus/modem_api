#!/bin/bash
#
# This script converts SMS encoded with UTF-8 to UCS2 format expected by smsd.
# To use it, edit your /etc/smsd.conf and add the following line:
#
#    checkhandler = /path/to/smstools-utf8-to-ucs2.sh
#
# When creating a new message in /var/spool/outgoing/, add the following header line:
#
#    Alphabet: UTF-8
#
# Download SMS tools from http://smstools3.kekekasvi.com/
# Latest version of this script at https://gist.github.com/gists/2215142
# Author: Artur Bodera <abodera@gmail.com>
#
if sed -e '/^$/ q' < "$1" | grep "^Alphabet: UTF-8" > /dev/null; then
    TMPFILE=`mktemp /tmp/smsd_XXXXXX`
    sed -e '/^$/ q' < "$1" | sed -e 's/Alphabet: UTF-8/Alphabet: UCS2/g' > $TMPFILE
    sed -e '1,/^$/ d' < $1 | iconv -f UTF-8 -t UNICODEBIG >> $TMPFILE
    mv -f $TMPFILE $1
fi
