#!/bin/bash

readonly TMPDIR=/tmp
readonly CONFIG=/www/config
readonly BUPDIR=/root/backup
readonly RANGE=300
readonly URL="https://plugunplug.net/update/update-weekly.tar.gz"

if [ -f $CONFIG/networkstate ]; then
    if [ $(cat $CONFIG/networkstate) == "online" ]; then
        number=$RANDOM
        let "number %= $RANGE"
        echo sleeping for $number
        sleep $number
        cd $TMPDIR
        rm -f update-daily.tar.gz
        # We verify file integrity with GnuPG so no need for https://
        echo "Retreiving update package"
        curl -O --insecure $URL 
        echo "Downloading signature"
        curl -O --insecure $URL.gpg 
        echo "verifying..."
        CHECKSIG=$(gpg --status-fd 1 --verify update-weekly.tar.gz.gpg update-weekly.tar.gz | grep -o VALIDSIG)
        if [[ "$CHECKSIG" == VALIDSIG ]]
            then
                echo "Appears to be a trustworthy archive. Backing up existing config..."	
                touch $CONFIG/updated
                echo "Backing up existing files..."
                FULLDATE=$(date +%Y-%m-%d_%H-%M-%S)
                tar cvzf $BUPDIR/update-$FULLDATE.tar.gz /etc /root/scripts /www
                echo "Extracting archive..."
                # tar xvzf update-weekly.tar.gz -C $TMPDIR
                tar xvzf update-weekly.tar.gz -C / 
                #reboot
        fi
    fi
fi
