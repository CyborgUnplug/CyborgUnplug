#!/bin/bash

CONFIG=/www/config/

if [ ! -f $CONFIG/since ]; then

	RANGE=255
	VENDOR='00:1F:1F' # Edimax
	VENDOR2='00:17:A5' # Ralink

	rangen() {
		NUM=$RANDOM
		let "NUM %= $RANGE"
		OCT=$(echo "obase=16;$NUM" | bc)
		if [ ${#OCT} == 1 ]; then
		    OCT='0'$OCT
		fi
		echo $OCT
	}

	A=$(rangen)
	B=$(rangen)
	C=$(rangen)
	D=$(rangen)
	E=$(rangen)

	ETH0="${VENDOR}:${A}:${B}:${C}"
	ETH1="${VENDOR}:${A}:${B}:${D}"
	ETH2="${VENDOR}:${B}:${D}:${A}"
	WLAN="${VENDOR2}:${A}:${B}:${E}"

	echo $ETH0 > $CONFIG/eth0mac
	echo $ETH1 > $CONFIG/eth1mac
	echo $ETH2 > $CONFIG/eth2mac
	echo $WLAN > $CONFIG/wlanmac

fi

ifconfig eth0 down
ifconfig eth0.1 down
ifconfig eth0.2 down

ifconfig eth0 hw ether $(cat $CONFIG/eth0mac)
ifconfig eth0.1 hw ether $(cat $CONFIG/eth1mac)
ifconfig eth0.2 hw ether $(cat $CONFIG/eth2mac)
ifconfig eth0 up

