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
readonly RANGE=300
readonly NOW=$1
readonly URL="https://plugunplug.net/update/update-weekly.sh"

REBOOT=0

if [ -f $CONFIG/networkstate ]; then
    if [[ $(cat $CONFIG/networkstate) == "online" ]]; then
        cd $UPDIR
        # Check to see if update should be for "now"
        if [ $NOW -ne 1 ]; then
            number=$RANDOM
            let "number %= $RANGE"
            echo sleeping for $number
            sleep $number
        else
            REBOOT=1
        fi
        # We verify file integrity with GnuPG (a la Debian package signing) so
        # no need for https://
        echo "Retreiving update script..."
        curl -O --insecure $URL 
        echo "Downloading signature"
        curl -O --insecure $URL.gpg 
        echo "verifying..."
        CHECKSIG=$(gpg --status-fd 1 --verify update-weekly.sh.gpg update-weekly.sh | grep -o VALIDSIG)
        if [[ "$CHECKSIG" == VALIDSIG ]]
            then
                echo "Appears to be trustworthy..."	
                touch $CONFIG/updated
                chmod +x update-weekly.sh # just in case
        fi
        if [ $REBOOT -ne 0 ]; then
            /sbin/reboot 
            echo "Rebooting to apply updates..."
        fi
    fi
fi
