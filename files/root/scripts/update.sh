#!/bin/bash

# Copyright (C) 2015 Julian Oliver 
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

readonly CONFIG=/www/config
readonly UPDIR=/root/update
readonly CACHE=$UPDIR/cache
readonly RANGE=300
readonly NOW=$1
readonly URL="https://plugunplug.net/update/"
readonly ARCHIVE='update.tar.gz'
readonly LOG=/var/log/update.log

#REBOOT=0

if [ -f $CONFIG/networkstate ]; then
    if [[ $(cat $CONFIG/networkstate) == "online" ]]; then
        cd $UPDIR
        # Check to see if update should be for "now"
        if [[ $NOW -ne 1 ]]; then
            number=$RANDOM
            let "number %= $RANGE"
            echo sleeping for $number
            sleep $number
        fi
        # We verify file integrity with GnuPG (a la Debian package signing) so
        # no need for SSL 
        echo "Downloading signature"
        curl -O --insecure $URL$ARCHIVE.gpg 
        if [ -f $ARCHIVE.gpg ]; then 
            # Check for difference, if yes, continue
            if ! cmp -s lastsig.gpg $ARCHIVE.gpg; then
                echo "Retreiving archive..."
                curl -O --insecure $URL$ARCHIVE 
                # Check for validity against sig
                echo "verifying..."
                CHECKSIG=$(gpg --status-fd 1 --verify $ARCHIVE.gpg $ARCHIVE | grep -o VALIDSIG)
                if [[ "$CHECKSIG" == VALIDSIG ]]; then
                        echo "Appears to be trustworthy..."	
                        tar xvzf $ARCHIVE # untar here
                        chmod +x upgrade.sh # just in case
                        touch $CONFIG/upgrade
                        if [[ $NOW -eq 1 ]]; then
                            #/sbin/reboot 
                            echo "Applying updates..."
                            # For control, do clean ups, reboots etc in the script itself
                            ./upgrade.sh &> $LOG 
                            if [[ ! $? -eq 0 ]]; then 
                                echo "Something went wrong with the update. Check log"
                            fi
                            rm -f $CONFIG/upgrade
                        fi
                fi
            fi
        else
            echo "Archive couldn't be downloaded. Postponing.."
        fi
    fi
fi
