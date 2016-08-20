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
readonly UDIR=/root/update
readonly LOGS=/www/admin/logs                               
readonly CONFIG=/www/config                                                                       
readonly DATA=/www/data                                             
readonly RESETDIR=/root/reset
readonly POLLTIME=5                                          
readonly WIFIDEV=radio0                                                             

# Check for a reset demand
if [ -f $RESETDIR/resetnow ]; then
    rm -f $CONFIG/email
    cp -a $RESETDIR/fs/* /
    rm -fr $RESETDIR/fs
    rm -f $RESETDIR/resetnow
    date > $RESETDIR/lastreset
fi

# Start the reset watchdog
$SCRIPTS/reset.sh &

mkdir /tmp/{keys,config}
# only readable by owner 
chmod go-rw /tmp/keys

# Our blink pattern control handle
mkfifo /tmp/blink

# Read from it
$SCRIPTS/blink.sh /tmp/blink &

# Fix the eth0-no-MAC issue. 
# TODO: fix it permanently!
$SCRIPTS/ethfix.sh

if [ -f $CONFIG/upgrade ]; then                               
    echo "upgrading..." 
    # run the update script now
    $UDIR/upgrade.sh &> $LOGS/upgrade.log
    rm -f $CONFIG/upgrade
    # we'll handle reboots in the update script itself, for more control
    # reboot 
fi

#Start networking
/etc/init.d/network start

# Give the network some time to come up
sleep 5


# Start the automounter
block umount; block mount

# Bring up the AP
$SCRIPTS/wifi.sh ap

# Setup GPIO for indicator LED
#$SCRIPTS/gpio.sh

# Scanning is done with a randomly generated NIC (TY mac80211!)
# The scan.sh script brings up the wireless NIC for us and sets 
# it in Monitor mode.
echo "Scanning for networks..."
$SCRIPTS/wifi.sh scan
echo "Found the following.."
cat $DATA/networks

chown nobody:nogroup $CONFIG/vpnstatus
echo unconfigured > $CONFIG/vpnstatus

# Disable wifi (incl hostapd) for the next boot as we want to 
# manage bringing up wifi on our own terms.
#uci set wireless.@wifi-iface[0].disabled=1
#uci commit

if [ ! -f $CONFIG/since ]; then
    # First boot!
    cp /www/admin/start.php /www/admin/index.php                                 
    /etc/init.d/cron enable 
    echo "<center><footer><hr>" >  /www/admin/footer.php
    echo "model: World solo | id: " $(cat $CONFIG/wlan0mac | sed 's/://g')" | rev: " $(cat $CONFIG/rev) >> /www/admin/footer.php 
    echo "</footer></center></div></body></html>" >> /www/admin/footer.php
    ln -s /www/admin/footer.php /www/share/footer.php
else
    if [ ! -f $CONFIG/email ]; then
        cp /www/admin/start.php /www/admin/index.php                                 
    else
        # Copy our config site page to index.php                              
        cp /www/admin/index.php.conf /www/admin/index.php                                 
    fi
    # Update the revision string 
    sed -i "/rev:/ s/rev:.*/rev:\ $(cat $CONFIG/rev)/" /www/admin/footer.php
    rm -f $CONFIG/armed                            
    rm -f $CONFIG/networks        
    rm -f $CONFIG/targets
    rm -f $CONFIG/mode                                 
    rm -f $CONFIG/vpn
    rm -f $CONFIG/setwifi
    rm -f $LOGS/detected                                           
fi

# Update the date on this file if it exists, create it if not
touch $CONFIG/since

#stunnel /etc/stunnel/stunnel.conf

# Start the LED blinker
echo idle > /tmp/blink

# Start the pinger
$SCRIPTS/ping.sh &

/etc/init.d/cron start

while true;   
    do        
        if [ -f $CONFIG/armed ]; then
                # We start the VPN manually in detect.sh and sweep.sh for 
                # privately dispatching alerts by email 
                MODE=$(cat $CONFIG/mode)
                sleep 5 # Grace time for final configuration page to load
                if [[ "$MODE" == "sweep" ]]; then
                    echo "Doing a sweep..."
                    $SCRIPTS/sweep.sh # This script exists on its own 
                    echo idle > /tmp/blink
                else
                    echo "Starting detector..."
                    $SCRIPTS/detect.sh &
                    exit # There's no going back after this, a set state
                fi
        elif [ -f $CONFIG/setwifi ]; then
                $SCRIPTS/wifi.sh ap 
                rm -f $CONFIG/setwifi
        elif [ -f $CONFIG/setbridge ]; then
                $SCRIPTS/wifi.sh bridge 
                rm -f $CONFIG/setbridge
                rm -f $CONFIG/bridge
        elif [[ -f $CONFIG/vpn && ! -f $CONFIG/armed ]]; then
                $SCRIPTS/vpn.sh 
        fi
        sleep $POLLTIME
done
