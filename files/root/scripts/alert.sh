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
readonly REMOTE=10.10.13.1
readonly PORT=25
readonly CONFIG=/www/config
readonly DATE=$(date)
readonly DEVICE=$1 # devices seen
readonly MAC=$2 # device MAC addr

if [[ "$DEVICE" == "none" ]]; then
body="Subject: Cyborg Unplug Notification 
From: alerts@vpn.plugunplug.net
-------------------------------------------------------------------------------
No specified devices were detected as of $DATE.

Please note this is not hard evidence that the devices you've selected for
detection are not present; they may be switched off or have networking disabled.

Nonetheless, if you feel your location and/or situation is volatile you should
leave the detector running. Also be sure to run the detector if you leave and
later return to the volatile location.

Yours,

Little Snipper
-------------------------------------------------------------------------------
"
else    
body="Subject: Cyborg Unplug Alert
From: alerts@vpn.plugunplug.net
-------------------------------------------------------------------------------
On $DATE, the following device was detected:

    $DEVICE with Hardware Address: $MAC

Please note this is not hard evidence that the above device was present; there
is always a small chance someone is using a spoofed MAC (hardware) address,
resulting in it coming up in my scans. 

Nonetheless, it's certainly a cause for concern and I thought you should know.

Yours,

Little Snipper
-------------------------------------------------------------------------------

"
fi

if [ -f $CONFIG/email ]; then
    readonly ADDR=$(cat $CONFIG/email)
    if [ ! -z $ADDR ]; then
        echo "$body" | msmtp --read-envelope-from -t "$ADDR"
    fi
else 
    echo "no email address configured."
fi
