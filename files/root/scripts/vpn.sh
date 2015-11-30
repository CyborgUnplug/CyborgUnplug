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
OVPN=/tmp/upload # must chmod this root-only read/write
LOG=/var/log/openvpn.log
POLLTIME=5
ETH=eth0
STATUS=$(cat $CONFIG/vpnstatus)
STARTED=0
TUN=""

vpnup () {
    if [[ $STARTED != 1 && $STATUS == "started" ]]; then
        echo "Attempting to bring up VPN..."
        ifconfig $ETH up 
        VPNARGS=($(cat $CONFIG/vpnargs)) # array
        ARG1=${VPNARGS[0]}
        ARG2=${VPNARGS[1]}
        if [ $ARG1 == 1 ]; then
            AUTH=$OVPN/$ARG2.auth 
            $BINPATH/openvpn --config $OVPN/$ARG2 --auth-user-pass $AUTH > $LOG & #--inactive 30 --ping 10 --ping-exit 60 &
        else
            $BINPATH/openvpn --config $OVPN/$ARG2 --inactive 30 --ping 10 --ping-exit 60 &
        fi
        VPNPID=$!
        if [ ! -z "$VPNPID" ]; then
            echo "we have a VPNPID" $VPNPID
            while [ $STATUS == "started"  ];
                do 
                    if ! ifconfig | grep -q tun[0-9]; then 
                        echo "waiting for tun to come up"
                        sleep 1 
                    else
                        echo up > $CONFIG/vpnstatus
                        echo "VPN is up"
                        echo 3 | $SCRIPTS/ledfifo 
                        STARTED=1
                        break
                    fi
                    STATUS=$(cat $CONFIG/vpnstatus)
                done
        fi 
    else 
        VPNPID=$(ps | grep [open]vpn)
        if [ -z "$VPNPID" ]; then
            echo "made it to here, VPNPID = " $VPNPID > /tmp/log
            # immediately take down our WAN interface to stop leaks 
            ifconfig $ETH down
            echo "VPN is down"
            echo down > $CONFIG/vpnstatus
            STARTED=0
        else
            echo "All seems fine. Passing this round"
        fi
    fi
    #cat /www/config/vpnstatus
}

vpndown() {
    VPNPID=$(ps | grep [open]vpn)
    if [ ! -z "$VPNPID" ]; then
        killall -SIGTERM openvpn
        echo "Killed OpenVPN"
        # immediately take down our wired WAN interface to stop leaks.
        # 'eth0' is easiest to work with on this platform as it brings down/up eth0.1, eth0.2.
        ifconfig $ETH down
        rm -f $OPVN/*
        STARTED=0
        echo unconfigured > /www/config/vpnstatus
    fi
}

while true; 
    do
        STATUS=$(cat $CONFIG/vpnstatus)
        echo "OpenVPN status: " $STATUS
        case "$STATUS" in
            *up*)
                vpnup
            ;;
            *stopped*)
                vpndown 
                #rm -f $CONFIG/vpnargs
            ;; 
            *started*)
                vpnup
            ;; 
            #*unconfigured*)
                #vpndown 
                #rm -f $CONFIG/vpnargs
                #rm -f /www/upload/*
            #;; 
            *)
        esac
        sleep $POLLTIME
    done
    
    
