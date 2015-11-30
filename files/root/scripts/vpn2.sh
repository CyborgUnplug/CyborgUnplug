#!/bin/bash

BINPATH=/usr/sbin/
CONFIG=/www/config
OVPN=/www/upload
LOG=/var/log/openvpn.log
POLLTIME=5

STATUS=$(cat $CONFIG/vpnstatus)
STARTED=0
TUN=""

vpnup () {
    if [[ $STARTED != 1 && $STATUS == "started" ]]; then
        echo "Attempting to bring up VPN..."
        VPNARGS=($(cat $CONFIG/vpnargs))
        ARG1=${VPNARGS[0]}
        ARG2=${VPNARGS[1]}
        if [ $ARG1 == 1 ]; then
            AUTH=$OVPN/$ARG2.auth 
            $BINPATH/openvpn --config $OVPN/$ARG2 --auth-user-pass $AUTH --inactive 3600 --ping 10 --ping-exit 60 &
        else
            $BINPATH/openvpn --config $OVPN/$ARG2 --inactive 3600 --ping 10 --ping-exit 60 &
        fi
        VPNPID=$!
        if [ ${#VPNPID} -gt 1 ]; then
            while true;
                do 
                    TUN=$(ifconfig | grep -o tun[0-9])
                    if [ ${#TUN} -lt 1 ]; then 
                        echo "waiting for tun to come up"
                        sleep 1 
                    else
                        echo up > $CONFIG/vpnstatus
                        echo "VPN is up"
                        STARTED=1
                        break
                    fi
                done
        fi 
    else 
        VPNPID=$(ps | grep [open]vpn | awk '{ print $1 }')
        if [ ${#VPNPID} -lt 1 ]; then
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
    VPNPID=$(ps | grep [open]vpn | awk '{ print $1 }')
    if [ ${#VPNPID} -gt 1 ]; then
        killall -SIGTERM openvpn
        echo "Killed OpenVPN"
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
            *unconfigured*)
                vpndown 
                #rm -f $CONFIG/vpnargs
                #rm -f /www/upload/*
            ;; 
            *started*)
                vpnup
            ;; 
            *)
        esac
        sleep $POLLTIME
    done
    
    
