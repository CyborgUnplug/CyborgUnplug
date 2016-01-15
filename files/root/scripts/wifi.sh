#!/bin/bash

CONFIG=/www/config

# Derive a unique ESSID from wifi NIC's MAC on first boot
if [ ! -f $CONFIG/since ]; then
    STOCKSSID=unplug_$(cat $CONFIG/wlanmac | cut -d ':' -f 5-8 | sed 's/://g')
    echo $STOCKSSID > $CONFIG/ssid # Needed for UI later
	MAC=$(cat $CONFIG/wlanmac)
	
	# Pseudo-randomly generate a channel for our AP
	RANGE=13
	CHAN=$RANDOM
	let "CHAN %= $RANGE"
	uci set wireless.@wifi-iface[0].ssid=$STOCKSSID
	uci set wireless.@wifi-iface[0].macaddr=$MAC
	uci set wireless.@wifi-iface[0].channel=$CHAN
        uci commit wireless
fi
# Bring up Access Point
wifi down
#ifconfig wlan0 hw ether $(cat $CONFIG/wlanmac)
uci set wireless.@wifi-iface[0].disabled=0
uci set wireless.@wifi-iface[0].mode="ap"

if [ -f /tmp/config/wlanpw ]; then
    PW=$(cat /tmp/config/wlanpw)
    uci set wireless.@wifi-iface[0].key=$PW
    rm -f /tmp/config/wlanpw
fi
if [ -f $CONFIG/ssid ]; then
    SSID=$(cat $CONFIG/ssid)
    uci set wireless.@wifi-iface[0].ssid=$SSID
    #rm -f /www/config/ssid
fi
if [ -f $CONFIG/channel ]; then
    CHANNEL=$(cat $CONFIG/channel)
	uci set wireless.@wifi-iface[0].channel=$CHANNEL
    rm -f /www/config/channel
fi

uci commit wireless
echo "Bringing up AP..."
wifi

uci set wireless.@wifi-iface[0].disabled=1
uci commit wireless

# Wait for hostapd to come up before exiting
while true;
    do
	HAPD=$(ps | grep [ho]st | awk '{ print $1 }')
        if [ ! -z "$HAPD" ]; then
	    sleep 1
	else
	    echo "AP should be up" 
	    # Restart dnsmasq (DHCP)
	    /etc/init.d/dnsmasq restart
        # wlan0 IP is unset - for some reason - on the ar71xx by dnsmasq
        # Must set again
        ifconfig wlan0 10.10.10.1 up 
	    exit
	fi
    done
