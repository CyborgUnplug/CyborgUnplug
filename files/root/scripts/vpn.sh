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
OVPN=/tmp/keys # chmod'd root-only read/write 
LOG=/var/log/openvpn.log # only used for debugging
POLLTIME=5
ETH=eth0.2 # WAN interface
STATUS=$(cat $CONFIG/vpnstatus)
TUN=""
STARTED=0

vpnstart () {
    if [[ $STATUS == "start" && $STARTED != 1 ]]; then
        echo "Attempting to bring up VPN..."
        ifconfig $ETH up # in case taken down here earlier
        #killall -SIGTERM openvpn
        VPNARGS=($(cat $CONFIG/startvpn)) # array
        ARG1=${VPNARGS[0]}
        ARG2=${VPNARGS[1]}
        if [[ $ARG1 == 1 ]]; then
            AUTH=$OVPN/$ARG2.auth 
            $BINPATH/openvpn --config $OVPN/$ARG2 --up-restart --up "/root/scripts/up.sh" --down "/root/scripts/down.sh" --script-security 2 --auth-user-pass $AUTH > /dev/null & 
        else
            $BINPATH/openvpn --config $OVPN/$ARG2 --up-restart --up "/root/scripts/up.sh" --down "/root/scripts/down.sh" --script-security 2 > /dev/null &
        fi
        COUNT=0
        while [[ ! -z $(ps | grep [open]vpn) ]];
            do
                STARTED=1
                STATUS=$(cat $CONFIG/vpnstatus)
                if [[ $STATUS != "up" ]]; then
                    if [ $COUNT -lt 20 ]; then
                        let "COUNT+=1"
                        echo "Count $COUNT with PID $VPNPID. Waiting for tun/tap to come up"
                        sleep 1 
                    else
                        echo "Failed to reach remote host, bailing out..."
                        vpnstop
                        return 1 
                    fi
                else
                    echo "tun/tap device is up"
                    echo "Updating date"
                    ntpd -q -n -p 0.openwrt.pool.ntp.org # don't daemonise, quit after setting
                    return 0 
                fi
        done
        echo "OpenVPN process died, bailing out..."
        vpnstop
        return 1
    fi
}

vpncheck () {
    # VPNPID=$(ps | grep [open]vpn | awk '{ print $1 }') # PID not reliable, zombie procs
    TUN=$(ifconfig | grep -e tun -e tap)
    if [ -z "$TUN" ]; then
        echo "VPN is down, do stuff here...."
        # VPN was in use, so take down WAN NIC immediately, to avoid leaks
        ifconfig $ETH down
        echo down > $CONFIG/vpnstatus
        killall -SIGTERM openvpn # zombie processes
    else
        # do test ping here
        echo "VPN status is: " $(cat $CONFIG/vpnstatus)
        echo "tun/tap is up"
        echo 3 > $SCRIPTS/ledfifo 
        #cat /www/config/vpnstatus
    fi
}

vpnstop() {
    VPNPID=$(ps | grep [open]vpn)
    STARTED=0
    if [ ! -z "$VPNPID" ]; then
        killall -SIGTERM openvpn
        echo "Killed OpenVPN process"
    fi
    echo "VPN is down"
    #ifconfig $ETH down
    #rm -f $OVPN/*
    echo unconfigured > $CONFIG/vpnstatus
    echo 2 > $SCRIPTS/ledfifo 
}

while true; 
    do
        STATUS=$(cat $CONFIG/vpnstatus)
        echo "OpenVPN status: " $STATUS
        case "$STATUS" in
            *up*)
                vpncheck 
            ;;
            *stop*)
                vpnstop 
            ;; 
            *start*)
                vpnstart
            ;; 
            *)
        esac
        sleep $POLLTIME
    done
    
    
