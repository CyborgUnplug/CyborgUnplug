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

readonly SCRIPTS=/root/scripts
readonly UPDIR=/root/update
readonly LOGS=/www/logs                               
readonly CONFIG=/www/config                                                                       
readonly DATA=/www/data                                             
readonly POLLTIME=5                                          
readonly WIFIDEV=radio0                                                             


mkdir /tmp/keys
mkdir /tmp/config
# only readable by owner 
chmod go-rw /tmp/keys

# Fix the eth0-no-MAC issue. 
# TODO: fix it permanently!
## $SCRIPTS/ethfix.sh

##DISABLED in 'homebake' release
##if [ -f $CONFIG/updated ]; then                               
#    echo "updating..." 
#    # run the update script now
#    $UPDIR/update-weekly.sh
#    rm -f $CONFIG/updated
#    reboot
#fi

#Start networking
/etc/init.d/network start

# Give the network some time to come up
sleep 5

# Take down the radio device
#wifi down $WIFIDEV

# Start the automounter
block umount; block mount

# Setup GPIO for indicator LED
##$SCRIPTS/gpio.sh

if [ ! -f $CONFIG/since ]; then
    ifconfig
    ifconfig | grep wlan0 | head -n 1 | awk '{ print $ 5 }' > $CONFIG/wlanmac
    /etc/init.d/cron enable 
    echo "<center><footer><hr>" >  /www/footer.php
    echo "Model: homebake | id: " $(cat $CONFIG/wlanmac | sed 's/://g')      >> /www/footer.php 
    echo "</footer></center></div></body></html>" >> /www/footer.php
else
    # Copy our config site page to index.php                              
    cp /www/index.php.conf /www/index.php                                 
    rm -f $CONFIG/armed                            
    rm -f $CONFIG/networks        
    rm -f $CONFIG/targets
    rm -f $CONFIG/mode                                 
    rm -f $CONFIG/vpn
    rm -f $CONFIG/startvpn
    rm -f $LOGS/detected                                           
fi

# Scanning is done with a randomly generated NIC (TY mac80211!)
# The scan.sh script brings up the wireless NIC for us and sets 
# it in Monitor mode.
echo "Scanning for networks..."
$SCRIPTS/scan.sh               
echo "Found the following.."
cat $DATA/networks

chown nobody:nogroup /www/config/vpnstatus
echo unconfigured > /www/config/vpnstatus

# Disable wifi (incl hostapd) for the next boot as we want to 
# manage bringing up wifi on our own terms.
#uci set wireless.@wifi-iface[0].disabled=1
#uci commit

## DISABLED
## useless without a configured SMTP server for delivery
#if [ ! -f $CONFIG/email ]; then
#    cp /www/start.php /www/index.php                                 
#fi

# Bring up the AP
$SCRIPTS/wifi.sh

#stunnel /etc/stunnel/stunnel.conf

### Start the LED blinker
##$SCRIPTS/blink.sh idle 

# Start the pinger
$SCRIPTS/ping.sh &

/etc/init.d/cron start

# Update the date on this file. Also acts as a firstboot.
touch $CONFIG/since

while true;   
    do        
        if [ -f $CONFIG/armed ]; then
                MODE=$(cat $CONFIG/mode)
                sleep 5 # Grace time for final configuration page to load
                if [[ "$MODE" == "sweep" ]]; then
                    echo "Doing a sweep..."
                    $SCRIPTS/sweep.sh # This script exists on its own 
                else
                    echo "Starting detector..."
                    $SCRIPTS/detect.sh &
                    exit                                             
                fi
        fi
        if [ -f $CONFIG/vpn ]; then
                echo "Starting the VPN"
                $SCRIPTS/vpn.sh
        fi
        if [ -f $CONFIG/setwifi ]; then
                $SCRIPTS/wifi.sh 
                rm -f $CONFIG/setwifi
        fi
        sleep $POLLTIME
done
