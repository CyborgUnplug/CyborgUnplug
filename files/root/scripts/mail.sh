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

readonly SCRIPTS=/root/scripts
readonly REMOTE=10.9.8.1
readonly PORT=20010
readonly CONFIG=/www/config
readonly DATE=$(date)
readonly EMAIL=$1
readonly SEEN=$2 # devices seen
readonly BODY="
-------------------------------------------------------------------
The following devices were detected by Little Snipper at $DATE

$SEEN 

Please note this is not hard evidence that device(s) are there as 
someone you could be using a spoofed MAC (hardware) address, 
resulting in it coming up in our scans. 

Nonetheless, it's cause for concern and we thought you should know.

Kind regards,

Little Snipper
-------------------------------------------------------------------
"
if [ -f $CONFIG/email ]; then
    readonly ADDR=$(cat $CONFIG/email)
    if [ ! -z $ADDR ]; then
        echo "$BODY" | msmtp -t $EMAIL -f "alerts@vpn.plugunplug.net"
    fi
else 
    echo "no email address configured."
fi
