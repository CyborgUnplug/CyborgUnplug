#!/bin/bash

# Cyborg Unplug detector script for RT5350f LittleSnipper. Detects and de-auths
# user-selected target devices resourced from /www/config/. 
# 
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

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
shopt -s nocasematch # Important

readonly SCRIPTS=/root/scripts
readonly LOGS=/www/logs/
readonly CAPDIR=/tmp
readonly CONFIG=/www/config
readonly FRAMES=5 # Number of de-auth frames to send. 10 a good hit/time tradeoff

# Read in the user selected target devices and build the target string.
readonly SRCT=$(cat $CONFIG/targets | cut -d "," -f 2)
readonly TARGETS='@('$(echo $SRCT | sed 's/\ /\*\|/g')'*)'

seen=()
apid=0

# Make the activity page the default site page for connections during detection
# (only available over Ethernet) 
cp /www/active.php /www/index.php
rm -f $LOGS/detected
echo "This is our target list: "$TARGETS > $LOGS/targets

airmon-ng stop mon0 
killall horst

# Set to station mode (taking down 'hostapd') so that we have control of the NIC
wifi down
uci set wireless.@wifi-iface[0].mode="sta"
uci set wireless.@wifi-iface[0].disabled="0"
uci commit wireless
wifi up
sleep 3 # Important

# Extract and define a variable for our wireless NIC and bring it up in Monitor
# mode. We use $NIC to capture rather than the mon0 device created below. This
# is useful as we can set the channel of $NIC on the fly with iwconfig,
# automatically setting the channel of the mon0 device used to de-auth in turn.
readonly NIC=$(iw dev | grep Interface | awk '{ print $2 }')
ifconfig $NIC down
iwconfig $NIC mode Monitor
ifconfig $NIC up
sleep 3 # Important

# Create a monitor device for aireplay-ng to de-auth with. Aireplay will only
# work with an airmon-ng mon device, not $NIC.
airmon-ng start $NIC 
sleep 3 # Important

# Bring up the admin default VPN for sending alerts to users
echo "0 plugunplug.ovpn" > $CONFIG/vpn # bring up Unplug VPN for alerts
echo "start" > $CONFIG/vpnstatus
$SCRIPTS/vpn.sh &
sleep 5 # a little extra time for the VPN

alert() {
    tmail=false
    # TODO resolve how long the LED notification should run. Reset to 'detect' once
    # the owner has been notified by email? 
    # Have we already seen this target? 
    if [[ ! " ${seen[@]} " =~ "$target" ]]; then
        # Add target to array
        seen=(${seen[@]} $target)
        tmail=true
    else
        tmail=false
    fi
    if [ "$tmail" = true ]; then
        if [[ $(cat $CONFIG/networkstate) == "online" ]]; then
            echo "Alerting Unplug owner"
            device=$(cat /www/data/devices | grep -i ${target:0:8} | cut -d ',' -f 1)
            $SCRIPTS/alert.sh "$device" $target &
            apid=$!
            # Log this for the report page
            echo $(date) "detected device" "$device" "with MAC addr" $target >> $LOGS/detected
        else
            echo "Can't send alert. Unplug not online"
        fi
    fi
}

# Start horst with upper channel limit of 13 in quiet mode and a command hook
# for remote control (-X). Has to be backgrounded.
horst -u 13 -q -i $NIC -o $CAPDIR/cap -X &
#hpid=$!

POLLTIME=13 # Seconds we wait for capture to find STA/BSSID pairs
horst -x channel_auto=1
horst -x pause 

COUNT=0

echo detect > /tmp/blink

while [ $COUNT -lt 6 ];
        do
            echo "//--------------------* $COUNT * ----------------------------------->"
            echo "Sleeping for " $POLLTIME " and writing capture log"
            echo detect > /tmp/blink
            sleep $POLLTIME
            # Sort associated clients into temporary pairing files. Channels are
            # not in the probed/association section of airodump-ng and so the
            # pairs need to be extraced and matched separately.
            cat $CAPDIR/cap | awk '{ print $2 $3 $4 $11 }' | sed 's/,/\ /g' | sort -u > $CAPDIR/pairs
            if [ -f $CAPDIR/pairs ]; then
                    while read line;
                             do
                                arr=($line) # Array from the line
                                src=${arr[0]}; dst=${arr[1]}; BSSID=${arr[2]}; freq=${arr[3]}
                                #echo $src $dst $BSSID $freq
                                if [[ $src != $BSSID ]]; then
                                    STA=$src
                                else 
                                    STA=$dst 
                                fi
                                if [[ "$STA" == $TARGETS ]]; then
                                    target=$STA
                                    alert
                                    echo target > /tmp/blink
                                elif [[ "$BSSID" == $TARGETS ]]; then
                                    target=$BSSID
                                    alert
                                    echo target > /tmp/blink
                                fi
                        done < $CAPDIR/pairs #EOF
                let 'COUNT += 1'
                echo "Removing temporary files."
                rm -f $CAPDIR/pairs $CAPDIR/channels 
                horst -x pause
                rm -f $CAPDIR/cap
                horst -x outfile=$CAPDIR/cap
                horst -x resume 
            fi
done

if [[ $(cat $CONFIG/networkstate) == "online" && ! -f $LOGS/detected ]]; then
        # in case a stuck alert.sh PID
        if [[ $apid != 0 ]]; then
            kill -9 $apid 
        fi
        echo "Notifying owner no devices have been detected"
        $SCRIPTS/alert.sh none 
fi

echo NULL > $CONFIG/mode
cp /www/index.php.conf /www/index.php

killall horst 
#kill -9 $hpid 
killall openvpn vpn.sh
sleep 1

# Set back to AP mode 
wifi down
uci set wireless.@wifi-iface[0].mode="ap"
uci set wireless.@wifi-iface[0].disabled="0"
uci commit wireless
wifi up

rm -f $CONFIG/vpn
echo unconfigured > $CONFIG/vpnstatus
rm -f $CONFIG/armed
killall dnsmasq # For some reason using /etc/init.d/ to pull it down doesn't work
/etc/init.d/dnsmasq start
echo idle > /tmp/blink
