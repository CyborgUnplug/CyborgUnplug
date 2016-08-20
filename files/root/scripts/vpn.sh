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

readonly SCRIPTS=/root/scripts
readonly BINPATH=/usr/sbin/
readonly CONFIG=/www/config
readonly EXTVPN=/tmp/keys # chmod'd root-only read/write 
readonly LOG=/var/log/openvpn.log # only used for debugging
readonly VPN=/root/keys/plugunplug.ovpn
readonly POLLTIME=5
readonly ETH=eth0.2 # WAN interface
readonly VPNSERVER=89.238.81.42
readonly GATEWAY=$(route -n | grep UG[^H] | awk '{ print $2 }')

STATUS=$(cat $CONFIG/vpnstatus)
TUN=""
STARTED=0

vpnstart () {
    if [[ $STATUS == "start" && $STARTED != 1 ]]; then
        echo "Attempting to bring up VPN..."
        if [ ! -f $CONFIG/bridge ]; then
            ifconfig $ETH up # in case taken down here earlier
        fi
        killall -SIGTERM openvpn
        killall stunnel
        local vpnargs=($(cat $CONFIG/vpn)) # array
        local arg1=${vpnargs[0]}
        local arg2=${vpnargs[1]}
        if [[ $arg1 == 1 ]]; then
            local auth=$EXTVPN/$arg2.auth 
            $BINPATH/openvpn --config $EXTVPN/$arg2 --up-restart --up "/root/scripts/up.sh" --down "/root/scripts/down.sh" --script-security 2 --auth-user-pass $auth > /dev/null & 
        else
            if [[ $arg2 == "plugunplug.ovpn" ]]; then 
                # Get us a fresh stunnel
                stunnel /etc/stunnel/stunnel.conf 
                # We need to call this function here as can't seem to be done
                # with --push directive in OpenVPN server side; the local gateway
                # is not known to the server.
                $BINPATH/openvpn --config $VPN --up-restart --up "/root/scripts/up.sh" --down "/root/scripts/down.sh" --script-security 2 > /dev/null &
                echo "Started Unplug VPN"
                routetoggle up
            else
                $BINPATH/openvpn --config $EXTVPN/$arg2 --up-restart --up "/root/scripts/up.sh" --down "/root/scripts/down.sh" --script-security 2 > /dev/null &
            fi
        fi
        count=0
        while [[ ! -z $(ps | grep [open]vpn) ]];
            do
                STARTED=1
                STATUS=$(cat $CONFIG/vpnstatus)
                if [[ "$STATUS" != "up" ]]; then
                    if [ $count -lt 120 ]; then
                        let "count+=1"
                        echo "Count $count. Waiting for tun/tap to come up"
                        sleep 1 
                    else
                        echo "Failed to reach remote host, bailing out..."
                        vpnstop
                        return 1 
                    fi
                else
                    echo "tun/tap device is up"
                    #echo "Updating date"
                    #ntpd -q -n -p 0.openwrt.pool.ntp.org & # don't daemonise, quit after setting
                    echo vpn > /tmp/blink
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
        if [ ! -f $CONFIG/bridge ]; then
            ifconfig $ETH down 
        fi
        routetoggle down
        echo down > $CONFIG/vpnstatus
        killall -SIGTERM openvpn # zombie processes
        rm $CONFIG/vpn
    else
        # do test ping here
        echo "VPN status is: " $(cat $CONFIG/vpnstatus)
        #cat /www/config/vpnstatus
    fi
}

vpnstop() {
    local vpnpid=$(ps | grep [open]vpn)
    STARTED=0
    if [ ! -z "$vpnpid" ]; then
        killall -SIGTERM openvpn
        echo "Killed OpenVPN process"
    fi
    echo "VPN is down"
    #ifconfig $ETH down
    #rm -f $EXTVPN/*
    routetoggle down
    echo unconfigured > $CONFIG/vpnstatus
    echo idle > /tmp/blink
    rm $CONFIG/vpn
    exit
}

routetoggle() {
    #/etc/init.d/dnsmasq stop
    killall dnsmasq
    if [ "$1" == up ]; then
        # Add our route
        # Take down the dnsmasq pocess
        # IMPORTANT: DNS LEAKS
        # Bring up dnsmasq with opts pushing all DNS queries to VPN server,
        # mitigating dangerous leaks
        dnsmasq -C /var/etc/dnsmasq.conf --dhcp-option=6,10.10.13.1
        sleep 1
        route add -net $VPNSERVER netmask 255.255.255.255 gw $GATEWAY
        sleep 1
    else 
        route del -net $VPNSERVER netmask 255.255.255.255 gw $GATEWAY
        # Take down the dnsmasq pocess
        # Bring it up again, with the LAN-wise defaults... 
        /etc/init.d/dnsmasq start 
    fi 
}

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
    
    
