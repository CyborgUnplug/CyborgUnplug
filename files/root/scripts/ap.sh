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

readonly CONFIG=/www/config

# Derive a unique ESSID from wifi NIC's MAC on first boot
if [ ! -f $CONFIG/since ]; then
    #readonly SSID=unplug_$(cat $CONFIG/wlanmac | cut -d ':' -f 5-8 | sed 's/://g')
    readonly SSID=unplug
    echo $SSID > $CONFIG/ssid # Needed for UI later
	readonly MAC=$(cat $CONFIG/wlanmac)
	
	# Pseudo-randomly generate a channel for our AP
	readonly RANGE=13
	CHAN=$RANDOM
	let "CHAN %= $RANGE"
	uci set wireless.@wifi-iface[0].ssid=$SSID
	uci set wireless.@wifi-iface[0].macaddr=$MAC
	uci set wireless.@wifi-iface[0].channel=$CHAN
fi
# Bring up Access Point
wifi down
#readonly SSID=$(cat $CONFIG/ssid)
#ifconfig wlan0 hw ether $(cat $CONFIG/wlanmac)
uci set wireless.@wifi-iface[0].disabled=0
uci set wireless.@wifi-iface[0].mode="ap"

uci commit wireless
echo "Bringing up AP..."
wifi

# Wait for hostapd to come up before exiting
while true;
    do
        local hapd=$(ps | grep [ho]st | awk '{ print $1 }')
        if [ ! $hapd ]; then
	    sleep 1
	else
	    echo "AP should be up with name: " $SSID
	    # Restart dnsmasq (DHCP)
	    /etc/init.d/dnsmasq restart
	    exit
	fi
    done
