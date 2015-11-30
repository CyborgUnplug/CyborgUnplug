#!/bin/bash

BINPATH=/usr/sbin/
CONFIG=/www/config
OVPN=/www/upload
LOG=/var/log/openvpn.log


STATUS=$(cat $CONFIG/vpnstatus)
TUN=$(ifconfig | grep -o tun[0-9])

echo "This is the status" $STATUS
if [ ${#TUN} -lt 1 ]; then
    echo "NO TUN"
    if [ -f /www/config/vpnargs ]; then
        VPNARGS=($(cat /www/config/vpnargs))
        ARG1=${VPNARGS[0]}
        ARG2=${VPNARGS[1]}
        if [[ $STATUS == "down" || $STATUS != "connecting" ]]; then 
            rm -f /var/log/openvpn.log
            if [ $ARG1 == 1 ]; then
                AUTH=$OVPN/$ARG2.auth 
                $BINPATH/openvpn --config $OVPN/$ARG2 --auth-user-pass $AUTH > $LOG &
            else
                $BINPATH/openvpn --config $OVPN/$ARG2 > $LOG &
            fi
            echo connecting > /www/config/vpnstatus
            sleep 5
        fi
        VPNFAIL=$(cat $LOG  | grep -io "[exi]ting")
        if [ $VPNFAIL ]; then
            echo "connection or auth issue. bailing out..."
            echo down > /www/config/vpnstatus
            rm -f /www/config/vpnargs
            exit
        fi
    else
        echo unconfigured > /www/config/vpnstatus
    fi
else
    echo up > /www/config/vpnstatus
    echo "have a tun device. we're up..."
    exit
fi

#iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o tun0 -j MASQUERADE
