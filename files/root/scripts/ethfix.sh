#!/bin/bash

readonly CONFIG=/www/config/

if [ ! -f $CONFIG/since ]; then

	readonly RANGE=255
	readonly VENDOR='00:1F:1F' # Edimax
	readonly VENDOR2='00:17:A5' # Ralink

	rangen() {
		local NUM=$RANDOM
		let "NUM %= $RANGE"
		local oct=$(echo "obase=16;$NUM" | bc)
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

	eth0="${VENDOR}:${a}:${b}:${c}"
	eth1="${VENDOR}:${a}:${b}:${d}"
	eth2="${VENDOR}:${b}:${d}:${a}"
	wlan="${VENDOR2}:${a}:${b}:${e}"

	echo $eth0 > $CONFIG/eth0mac
	echo $eth1 > $CONFIG/eth1mac
	echo $eth2 > $CONFIG/eth2mac
	echo $wlan > $CONFIG/wlanmac

fi

ifconfig eth0 down
ifconfig eth0.1 down
ifconfig eth0.2 down

ifconfig eth0 hw ether $(cat $CONFIG/eth0mac)
ifconfig eth0.1 hw ether $(cat $CONFIG/eth1mac)
ifconfig eth0.2 hw ether $(cat $CONFIG/eth2mac)
ifconfig eth0 up

