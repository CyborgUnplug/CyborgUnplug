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

SCRIPTS=/root/scripts
BINPATH=/usr/sbin/
CONFIG=/www/config
OVPN=/root/keys/plugunplug.ovpn # chmod'd root-only r/w 
LOG=/var/log/unplug.log # only used for debugging
POLLTIME=15
ETH=eth0.2 # WAN interface
TUN=""
STARTED=0

vpnstart () {
    NETSTATE=$(cat $CONFIG/networkstate)
    if [[ $NETSTATE == "online" && $STARTED != 1 ]]; then
        echo "Attempting to bring up VPN..."
        ifconfig $ETH up # in case taken down here earlier
        killall stunnel
        stunnel /etc/stunnel/stunnel.conf
        sleep 2
        ifconfig tun0 down
        killall -SIGTERM openvpn
        $BINPATH/openvpn --config $OVPN > /dev/null & 
        COUNT=0
        while [[ ! -z $(ps | grep [open]vpn) ]];
            do
                TUN=$(ifconfig | grep -e tun)
                if [ -z "$TUN" ]; then
                    if [ $COUNT -lt 60 ]; then
                        let "COUNT+=1"
                        echo "Count $COUNT with PID $VPNPID. Waiting for tun/tap to come up"
                        sleep 1 
                    else
                        echo "Failed to reach remote host, bailing out..."
                        COUNT=0
                        return 1 
                    fi
                else
                    echo "tun/tap device is up"
                    echo "Updating date"
                    ntpd -q -n -p 0.openwrt.pool.ntp.org # don't daemonise, quit after setting
                    STARTED=1
                    return 0 
                fi

            done
    fi
}

while true; 
    do
        vpnstart 
        sleep $POLLTIME
    done
    
    
