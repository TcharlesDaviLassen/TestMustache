#!/bin/sh
HOST='192.185.176.150'
USER='flexab00'
PASSWD='6jr0qYOl95'
FILE1='atu.zip'
FILE2='hash'

ftp -v -d -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
binary
cd public_html
cd java
del $FILE1
del $FILE2
put $FILE1
put $FILE2
quit
END_SCRIPT
exit 0