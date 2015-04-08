#!/bin/bash

TMPDIR=/tmp
WWWDIR=/www
BUPDIR=/root/backup
RANGE=300
FULLDATE=$(date +%Y-%m-%d_%H-%M-%S)
number=$RANDOM
let "number %= $RANGE"
#sleep $number
echo sleeping for $number
touch /tmp/foo
rm -f update-daily.tar.gz
echo "Retreiving update package"
wget http://dislocative.com/unplug/update/update-daily.tar.gz -P $TMPDIR 
echo "Downloading signature"
wget http://dislocative.com/unplug/update/update-daily.tar.gz.gpg 
echo "verifying..."
CHECKSIG=$(gpg --status-fd 1 --verify update-daily.tar.gz.gpg update-daily.tar.gz | grep -o VALIDSIG)
if [[ "$CHECKSIG" == VALIDSIG ]]
	then
		echo "Appears to be a trustworthy archive. Backing up existing config..."	
		touch $WWWDIR/config/updated
        echo "Backing up existing files..."
        tar cvzf $BUPDIR/$FULLDATE.tar.gz /etc /root/scripts /www
		echo "Extracting archive..."
		tar xvzf update-daily.tar.gz -C /
        reboot
fi
