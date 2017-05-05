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
readonly LOGS=/www/admin/logs/
#readonly DEBUG=/tmp/detect.log
readonly CAPDIR=/tmp
readonly CONFIG=/www/config
readonly FRAMES=5 # Number of de-auth frames to send. 10 a good hit/time tradeoff
readonly MODE=$(cat $CONFIG/mode) 

# For allout and alert modes. Determines time spent capturing, in seconds.
# Higher values = lower anxiety = less regular alerts. Will eventually be
# user-editable through UI
readonly ANXIETY=13

# Read in the user selected target devices and build the target string.
readonly SRCT=$(cat $CONFIG/targets | cut -d "," -f 2)
readonly TARGETS='@('$(echo $SRCT | sed 's/\ /\*\|/g')'*)'

networks='' # Placeholder. Technically redundant.
tseen=()
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
readonly NIC=$(iw dev | grep Interface | awk '{ print $2 }')
ifconfig $NIC down
iwconfig $NIC mode Monitor
ifconfig $NIC up
sleep 3 # Important

# Create a monitor device for aireplay-ng to de-auth with. Aireplay will only
# work with an airmon-ng mon device, not $NIC.
airmon-ng start $NIC 
sleep 3 # Important

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
        unplugvpn
    fi
else
    # There is no VPN currently used
    unplugvpn
fi

alert() {
    tmail=false
    tnow=$(date +'%s')
    # TODO resolve how long the LED notification should run. Reset to 'detect' once
    # the owner has been notified by email? 
    echo target > /tmp/blink
    # Have we already seen this target? 
    if [[ ! " ${tseen[@]} " =~ "$target" ]]; then
        # Add target to array, with last seen seconds set to now
        tt=$target"|"$tnow
        tseen=(${tseen[@]} $tt)
        tmail=true
    else
        # No associative arrays in this version of bash. 
        # Can't return index on match. Have to iterate
        for index in $(seq 0 $((${#tseen[@]}-1))); do
            # Calculate last seen delta
            tdelta=$(($tnow - ${tseen[$index]/$target|/}))
            # Send alerts no more than once every 5mins (to avoid spamming)
            if [[ $tdelta -gt 300 ]]; then
                # Remove old entry from array
                unset tseen[$index]
                tmail=true
            else
                # Don't send alert this round as device was just seen
                tmail=false
            fi
            echo "this is tdelta: "$tdelta
        done
    fi
    if [[ $(cat $CONFIG/networkstate) == "online" ]]; then
        if [ "$tmail" = true ]; then
            echo "Alerting Unplug owner"
            device=$(cat /www/data/devices | grep -i ${target:0:8} | cut -d ',' -f 1)
            # in case a stuck pid, from last time
            if [[ $apid != 0 ]]; then
                kill -9 $apid 
            fi
            $SCRIPTS/alert.sh "$device" $target &
            apid=$! # new PID 
            if [[ "$MODE" != "alarm" ]]; then
                echo $(date) "detected device" "$device" "with MAC addr" $target >> $LOGS/detected
            fi
        else
            echo "Device seen in the last 5 minutes, not alerting owner"
        fi
    else
        echo "Can't send alert. Unplug not online"
    fi
}

channelWalk(){
    # This is only for Territory mode as horst already has a random walk for all
    # channels
    trap "exit" INT
    while true;
        do 
            for c in ${CHANNELS[@]}
                do
                    horst -x channel=$c
                    sleep 1
                done
        done
}

# In alarm mode, we're looking for the pure presence of a device, and
# so watch for any packets from the target(s) - probe, data or otherwise
horst -u 13 -q -i $NIC -o $CAPDIR/cap -X &
HPID=$!
# Put things specific to alarm/alert mode here.
POLLTIME=$ANXIETY # Seconds we wait for capture to find STA/BSSID pairs
horst -x channel_auto=1

startt=$(date +'%s')

while true;
        do
            echo "//------------------------------------------------------->"
            echo "Sleeping for " $POLLTIME " and writing capture log"
            # Set the LED blinker to the detect pattern
            echo detect > /tmp/blink
            sleep $POLLTIME
            # Sort associated clients into temporary pairing files. Channels are
            # not in the probed/association section of airodump-ng and so the
            # pairs need to be extraced and matched separately.
            cat $CAPDIR/cap | awk '{ print $2 $3 $4 $11 }' | sed 's/,/\ /g' | sort -u > $CAPDIR/pairs
            if [ -f $CAPDIR/pairs ]; then
                if [[ "$MODE" == "territory" ]]; then
                    kill -STOP $CPID
                fi
                while read line;
                     do
                        arr=($line) # Array from the line
                        src=${arr[0]}; dst=${arr[1]}; BSSID=${arr[2]}; freq=${arr[3]}
                        echo $src $dst $BSSID $freq
                        if [[ $src != $BSSID ]]; then
                            STA=$src
                        else 
                            STA=$dst 
                        fi
                        if [[ "$STA" == $TARGETS ]]; then
                            target=$STA
                            alert
                        elif [[ "$BSSID" == $TARGETS ]]; then
                            target=$BSSID
                            alert
                        fi
                    done < $CAPDIR/pairs #EOF

            now=$(date +'%s')
            delta=$(( $now - $startt ))
            echo $delta
            # Notify owner if no target devices have been detected in 12 hours (43200 seconds)
            if [[ $(cat $CONFIG/networkstate) == "online" && $delta -gt 43200 && ! -f $LOGS/detected ]]; then
                    # in case a stuck alert.sh PID
                    if [[ $apid != 0 ]]; then
                        kill -9 $apid 
                    fi
                    echo "Notifying owner no devices have been detected"
                    $SCRIPTS/alert.sh none &
                    apid=$! # new PID
                    startt=$(date +'%s')
            fi
            echo "Removing temporary files."
            rm -f $CAPDIR/pairs $CAPDIR/channels 
            horst -x pause
            if [ "$MODE" == "territory" ]; then
                kill -CONT $CPID
            fi
            rm -f $CAPDIR/cap
            horst -x outfile=$CAPDIR/cap
            horst -x resume 
            fi
done

