#!/bin/sh

killall start.sh vpn.sh detect.sh openvpn 
/etc/init.d/lighttpd stop

mtd -r -f write $1 firmware
