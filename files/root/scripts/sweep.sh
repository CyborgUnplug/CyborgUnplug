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

# TODO: Integrate this into detect.sh on the USA and USA-solo models.

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
shopt -s nocasematch # Important

readonly SCRIPTS=/root/scripts
readonly LOGS=/www/admin/logs/
#readonly DEBUG=/tmp/detect.log
readonly CAPDIR=/tmp
readonly CONFIG=/www/config
readonly FRAMES=5 # Number of de-auth frames to send. 10 a good hit/time tradeoff

# Read in the user selected target devices and build the target string.
readonly SRCT=$(cat $CONFIG/targets | cut -d "," -f 2)
readonly TARGETS='@('$(echo $SRCT | sed 's/\ /\*\|/g')'*)'

readonly NIC=wlan0

vpnup=0;

seen=()
apid=0

# Make the activity page the default site page for connections during detection
# (only available over Ethernet) 
cp /www/admin/active.php /www/admin/index.php
rm -f $LOGS/detected
echo "This is our target list: "$TARGETS > $LOGS/targets

airmon-ng stop mon0 
killall horst

# Set to station mode (taking down 'hostapd') so that we have control of the NIC
wifi down
uci set wireless.@wifi-iface[0].mode="sta"
uci set wireless.@wifi-iface[0].disabled="0"
uci set wireless.@wifi-iface[1].disabled="1"
uci commit wireless
wifi up
# Set it back to AP so the AP's not dead on reboot
uci set wireless.@wifi-iface[0].mode="ap"
uci commit wireless

sleep 10 # Important

# Extract and define a variable for our wireless NIC and bring it up in Monitor
# mode. We use $NIC to capture rather than the mon0 device created below. This
# is useful as we can set the channel of $NIC on the fly with iwconfig,
# automatically setting the channel of the mon0 device used to de-auth in turn.
ifconfig $NIC down
iwconfig $NIC mode Monitor
ifconfig $NIC up
sleep 3 # Important


# Create a monitor device for aireplay-ng to de-auth with. Aireplay will only
# work with an airmon-ng mon device, not $NIC.
airmon-ng start $NIC 
sleep 3 # Important

rm -f /tmp/sweep.log

unplugvpn() {
        killall openvpn vpn.sh
        # bring up Unplug VPN for alerts
        echo "0 plugunplug.ovpn" > $CONFIG/vpn 
        echo "start" > $CONFIG/vpnstatus
        $SCRIPTS/vpn.sh &
        # A little extra time for the VPN. Make this a watchdog on VPN up state
        # in future
        sleep 30 
}

if [ -f $CONFIG/vpn ]; then
    if [[ $(cat $CONFIG/vpn) != *plugunplug* ]]; then  
        # Record prior VPN status
        vpnstatus=$(cat $CONFIG/vpnstatus)
        vpn=$(cat $CONFIG/vpn)
        unplugvpn
    else
        # We're already using the main Unplug VPN
        vpnup=1
    fi
else
    # There is no VPN currently used
    vpnup=-1
    unplugvpn
fi

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
echo NULL > $CONFIG/mode

while [ $COUNT -lt 3 ];
        do
            echo "//--------------------* $COUNT * ----------------------------------->"
            echo "Sleeping for " $POLLTIME " and writing capture log"
            echo detect > /tmp/blink
            sleep $POLLTIME
            # Sort associated clients into temporary pairing files. Channels are
            # not in the probed/association section of airodump-ng and so the
            # pairs need to be extraced and matched separately.
            cat $CAPDIR/cap | awk '{ print $2 $3 $4 $11 }' | sed 's/,/\ /g' | sort -u > $CAPDIR/pairs
            cat $CAPDIR/pairs
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
                echo $COUNT
                echo "Removing temporary files."
                rm -f $CAPDIR/pairs $CAPDIR/channels 
                horst -x pause
                rm -f $CAPDIR/cap
                horst -x outfile=$CAPDIR/cap
                horst -x resume 
            fi
done

if [[ $(cat $CONFIG/networkstate) == *online* && ! -f $LOGS/detected ]]; then
        # in case a stuck alert.sh PID
        if [[ $apid != 0 ]]; then
            kill -9 $apid 
        fi
        echo "Notifying owner no devices have been detected"
        $SCRIPTS/alert.sh none 
fi

cp /www/admin/index.php.conf /www/admin/index.php

killall horst 
#kill -9 $hpid 

if [ $vpnup == 0 ]; then
    killall openvpn vpn.sh
    echo $vpn > $CONFIG/vpn
    echo start > $CONFIG/vpnstatus
elif [ $vpnup == -1 ]; then
    killall openvpn vpn.sh
    echo idle > /tmp/blink
else
    echo vpn > /tmp/blink
fi

# Set back to AP mode 
wifi down
uci set wireless.@wifi-iface[0].mode="ap" 
uci set wireless.@wifi-iface[0].disabled="0"
uci commit wireless

sleep 10 # Important: time for the route to flush out
/etc/init.d/network restart

#rm -f $CONFIG/vpn
#echo unconfigured > $CONFIG/vpnstatus
rm -f $CONFIG/armed
killall dnsmasq # For some reason using /etc/init.d/ to pull it down doesn't work
/etc/init.d/dnsmasq start

