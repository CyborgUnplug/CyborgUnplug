#!/bin/bash

readonly SCRIPTS=/root/scripts
readonly CONFIG=/www/config
readonly DATA=/www/data/
readonly TMPSCAN=/tmp/scan
readonly NETWORKS=$DATA/networks
readonly DO=$1

# Interface 0 == wlan0 == wifi-iface[0] == ap/wifi
# Interface 1 == wlan0-1 == wifi-iface[1] == sta/wwan

# Derive a unique ESSID from wifi NIC's MAC on first boot

first () {
    # Check this!
    if [ ! -f $CONFIG/since ]; then
        STOCKSSID=unplug_$(cat $CONFIG/wlan0mac | cut -d ':' -f 5-8 | sed 's/://g')
        echo $STOCKSSID > $CONFIG/ssid # Needed for UI later
        MAC0=$(cat $CONFIG/wlan0mac)
        MAC1=$(cat $CONFIG/wlan1mac)
           
        # Pseudo-randomly generate a channel for our AP
        RANGE=13
        CHAN=$RANDOM
        let "CHAN %= $RANGE"
        uci set wireless.@wifi-iface[0].macaddr=$MAC0
        uci set wireless.@wifi-iface[0].ssid=$STOCKSSID
        uci set wireless.@wifi-iface[0].channel=$CHAN
        uci set wireless.@wifi-iface[1].macaddr=$MAC1
        uci commit wireless
    fi
}

scan () {

    NIC=wlan0
    rm -f $NETWORKS

    /usr/sbin/iwlist $NIC scan > $TMPSCAN

    ssids=($(cat /tmp/scan | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'))
    len=${#ssids[@]}

    for ssid in ${ssids[@]}
        do
            cell=$(sed -n "/$ssid/,/Cell/p" $TMPSCAN)
            # array (chan enc essid)
            cv=($(echo "$cell" | grep -E 'Channel:|Encryption|ESSID:' | sed 's/.*://'))
            chan=${cv[0]}
            enc=${cv[1]}
            essid=${cv[@]:2} # safer all-to-end for wildcards and whitespace in ESSIDs 
            #echo "$cell"
            if [[ $enc == "on" ]]; then
                # If this cell uses WPA
                if [[ "$cell" == *"WPA"* ]]; then
                    enc=wpa
                else
                    enc=wep
                fi 
            fi

            if [[ "$essid" == '""' ]]; then
                essid="hidden"
            fi

            essid=$(echo $essid | sed 's/"//g' | base64)
            echo $ssid","$essid","$chan","$enc >> $NETWORKS
             
        done
}

bridge () {
    if [ -f $CONFIG/bridge ]; then
        NIC="wlan0.1"
        IND=0
        wifi down

        # Ensure our sta NIC has values cleared 
        uci set wireless.@wifi-iface[1].disabled=0
        uci set wireless.@wifi-iface[0].disabled=0
        uci set wireless.@wifi-iface[1].ssid=""
        uci set wireless.@wifi-iface[1].channel=""
        uci set wireless.@wifi-iface[1].encryption=""
        uci set wireless.@wifi-iface[1].key=""
        WWAN=($(cat $CONFIG/bridge | awk -F ',' '{ print $1" "$2" "$3" "$4" "$5}'))
        WSSID=$(echo ${WWAN[1]} | base64 -d)
        if [ ! -z ${WWAN[4]} ]; then
            PW=$(echo ${WWAN[4]} | base64 -d)
            uci set wireless.@wifi-iface[1].key=$PW
            if [ ${WWAN[3]} == "wpa" ]; then
                uci set wireless.@wifi-iface[1].encryption='psk2'
            else
                uci set wireless.@wifi-iface[1].encryption='wep'
            fi
        fi
        uci set wireless.@wifi-iface[1].ssid=$WSSID
        uci set wireless.@wifi-iface[1].mode="sta"
        
        # Have to use same channel for our AP as that of that we're connected to
        #CHANNEL=$(cat /www/data/networks | grep $WWAN | cut -d ',' -f 3)
        CHANNEL=${WWAN[2]}
        uci set wireless.@wifi-iface[0].channel=$CHANNEL
        uci commit wireless
        # bring down our WAN ethernet NIC
        ifconfig eth0.2 down
        # Bring up the wifi
        echo "Bringing up STA on $WSSID.."
        wifi
        /etc/init.d/dnsmasq restart
    fi
}

ap () {
    NIC="wlan0"
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

    if [ "$DO" == "bridge" ]; then
        uci set wireless.@wifi-iface[0].channel=$CHANNEL
    else
        # Disable our sta NIC before bringing up WiFi
        uci set wireless.@wifi-iface[1].disabled=1
        if [ -f $CONFIG/channel ]; then
            # Reset channel to that in channel config
            CHANNEL=$(cat $CONFIG/channel)
            uci set wireless.@wifi-iface[0].channel=$CHANNEL
            rm -f /www/config/channel
        fi
    fi

    # Ensure our ap NIC is set to ap mode
    uci set wireless.@wifi-iface[0].disabled=0
    uci set wireless.@wifi-iface[0].mode="ap"
    uci commit wireless
    echo "Bringing up AP..."
    wifi
    # We need this set to disable0
    #uci set wireless.@wifi-iface[0].disabled=1
    uci commit wireless

}

first

echo "Mode is: $DO"

case "$DO" in 
    *ap*)
        echo "setting to AP mode"
        ap
    ;;
    *bridge*)
        echo "setting to AP/STA mode"
        # Always bring up STA first! Important!
        bridge
    ;;
    *scan*)
        echo "scanning..."
        scan
    ;;
    *)
esac



