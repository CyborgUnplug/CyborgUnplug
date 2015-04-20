#!/bin/bash

# Cyborg Unplug main start script for the TL-WR710. Invoked from /etc/rc.local
# on each boot.
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

#$SCRIPTS/gpio.sh

sleep 10

echo "Scanning for networks..."
$SCRIPTS/scan.sh               
echo "Found the following.."
cat $DATA/networks
 
# Derive a unique ESSID from the internal NIC
SSID=unplug_$(ifconfig -a | grep eth0.1 | cut -d ':' -f 5-8 | sed 's/://g')
 
# Bring up Access Point
wifi down $WIFIDEV
uci set wireless.@wifi-iface[0].mode="ap"
uci set wireless.@wifi-iface[0].ssid=$SSID
uci commit wireless
echo "Bringing up AP..."
wifi
 
echo "AP should be up with name: " $SSID

sleep 5                                                                       
# NIC names seem to change when taking wifi radio's up and down
NIC=$(iw dev | grep Interface | awk '{ print $2 }')
#ifconfig $NIC up                 
 
# Copy our config site page to index.php                              
cp /www/index.php.conf /www/index.php                                 
                                                                   
#wifi up $WIFIDEV                    
NIC=$(iw dev | grep Interface | awk '{ print $2 }')
                                                                 
if [ ! -f $CONFIG/updated ]; then                               
    rm -f $CONFIG/armed                            
    rm -f $CONFIG/networks        
    rm -f $CONFIG/targets
    rm -f $CONFIG/mode                                 
    rm -f $LOGS/detected                                           
fi
                     
while true;   
    do        
        if [ -f $CONFIG/armed ]; then
                sleep 5 # Grace time for final configuration page to load
                echo "Starting detector..."
                $SCRIPTS/detect.sh &
                rm -f $CONFIG/updated # remove if it exists
                exit                                             
        fi
        sleep $POLLTIME
done
