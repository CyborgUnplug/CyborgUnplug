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
readonly REMOTE=10.10.12.1
readonly PORT=25
readonly CONFIG=/www/config
readonly DATE=$(date)
readonly DEVICE=$1 # devices seen
readonly MAC=$2 # device MAC addr

echo $DEVICE $MAC

readonly BODY="Subject: Cyborg Unplug Alert
From: alerts@vpn.plugunplug.net
-------------------------------------------------------------------
The following devices were detected by Little Snipper at:

$DATE

$DEVICE with Hardware Address: $MAC 

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
        echo "$BODY" | msmtp --read-envelope-from -t "$ADDR"
    fi
else 
    echo "no email address configured."
fi
