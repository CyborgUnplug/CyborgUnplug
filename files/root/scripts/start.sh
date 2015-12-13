#!/bin/bash

# Cyborg Unplug main start script for RT5350f LittleSnipper. Invoked from
# /etc/rc.local on each boot.
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

SCRIPTS=/root/scripts
LOGS=/www/logs                               
CONFIG=/www/config                                                                       
DATA=/www/data                                             
POLLTIME=5                                          
WIFIDEV=radio0                                                             


mkdir /tmp/keys
# only readable by owner 
chmod go-rw /tmp/keys

# Fix the eth0-no-MAC issue. 
# TODO: fix it permanently!
$SCRIPTS/ethfix.sh

#Start networking
/etc/init.d/network start

# Give the network some time to come up
sleep 5

# Take down the radio device
#wifi down $WIFIDEV

# Start the automounter
block umount; block mount

# Setup GPIO for indicator LED
#$SCRIPTS/gpio.sh

if [ ! -f $SCRIPTS/ledfifo ]; then 
    mkfifo $SCRIPTS/ledfifo
fi


# Scanning is done with a randomly generated NIC (TY mac80211!)
# The scan.sh script brings up the wireless NIC for us and sets 
# it in Monitor mode.
echo "Scanning for networks..."
$SCRIPTS/scan.sh               
echo "Found the following.."
cat $DATA/networks

# Bring up the AP
$SCRIPTS/wifi.sh
 
# Copy our config site page to index.php                              
cp /www/index.php.conf /www/index.php                                 
                                                                   
if [ ! -f $CONFIG/updated ]; then                               
    rm -f $CONFIG/armed                            
    rm -f $CONFIG/networks        
    rm -f $CONFIG/targets
    rm -f $CONFIG/mode                                 
    rm -f $CONFIG/startvpn
    rm -f $LOGS/detected                                           
fi

echo unconfigured > /www/config/vpnstatus

# Disable wifi (incl hostapd) for the next boot as we want to 
# manage bringing up wifi on our own terms.
#uci set wireless.@wifi-iface[0].disabled=1
#uci commit

# Update the date on this file. Acts as a firstboot.
touch $CONFIG/since

# Start the LED blinker
$SCRIPTS/blink.sh &

# Start the pinger
$SCRIPTS/ping.sh &

sleep 5

# Bring up the admin default VPN
$SCRIPTS/unplugvpn.sh &

while true;   
    do        
        if [ -f $CONFIG/armed ]; then
                sleep 5 # Grace time for final configuration page to load
                echo "Starting detector..."
                $SCRIPTS/detect.sh &
                rm -f $CONFIG/updated # remove if it exists
                exit                                             
        fi
        if [ -f $CONFIG/startvpn ]; then
                echo "Checking vpn..." $(date) >> /tmp/start.log
                #$SCRIPTS/vpn.sh &
                $SCRIPTS/vpn.sh 
                #exit                                             
        fi
        if [ -f $CONFIG/setwifi ]; then
                $SCRIPTS/wifi.sh 
                rm -f $CONFIG/setwifi
        fi
        sleep $POLLTIME
done
