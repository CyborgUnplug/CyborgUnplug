#!/bin/bash

uci set wireless.@wifi-iface[0].mode="sta"
uci commit wireless
wifi down
sleep 1
wifi up
sleep 1
NIC=$(iw dev | grep Interface | awk '{ print $2 }')
ifconfig $NIC down
iwconfig $NIC mode Monitor
ifconfig $NIC up 
iwconfig
