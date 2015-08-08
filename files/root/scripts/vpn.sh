#!/bin/sh

killall openvpn
openvpn --config /etc/openvpn/plugunplug.conf &
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o tun0 -j MASQUERADE
