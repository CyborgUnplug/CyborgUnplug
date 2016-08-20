#!/bin/bash

readonly CONFIG=/www/config/

if [ ! -f $CONFIG/since ]; then

	readonly RANGE=254 # Need max of 255, making room for max $f val below 
	readonly VENDOR='00:1F:1F' # Edimax
	readonly VENDOR2='00:17:A5' # Ralink

	rangen() {
		local num=$RANDOM
		let "num %= $RANGE"
		local oct=$(echo "obase=16;$num" | bc)
		if [ ${#oct} == 1 ]; then
		    oct='0'$oct
		fi
		echo $oct
	}

	a=$(rangen)
	b=$(rangen)
	c=$(rangen)
	d=$(rangen)
	e=$(rangen)

    # no idea why virtual NIC in sta mode /needs/ to be last field of radio MAC +1
    # But it does
    plusone() {
        p=$(echo "obase=16;$(( 0x$1 + 1 ))" | bc)
        if [ ${#1} == 1 ]; then
            p='0'$1
        fi
        echo $p
    }

    d_=$(plusone $d)
    e_=$(plusone $e)

	eth0="${VENDOR}:${a}:${b}:${c}"
	eth1="${VENDOR}:${a}:${b}:${d}"
	eth2="${VENDOR}:${a}:${b}:${d_}"
	wlan0="${VENDOR2}:${a}:${b}:${e}"
	wlan1="${VENDOR2}:${a}:${b}:${e_}"

	echo $eth0 > $CONFIG/eth0mac
	echo $eth1 > $CONFIG/eth1mac
	echo $eth2 > $CONFIG/eth2mac
	echo $wlan0 > $CONFIG/wlan0mac
	echo $wlan1 > $CONFIG/wlan1mac

fi

ifconfig eth0 down
ifconfig eth0.1 down
ifconfig eth0.2 down

ifconfig eth0 hw ether $(cat $CONFIG/eth0mac)
ifconfig eth0.1 hw ether $(cat $CONFIG/eth1mac)
ifconfig eth0.2 hw ether $(cat $CONFIG/eth2mac)
ifconfig eth0 up

