#!/bin/sh

killall openvpn
openvpn --config /etc/openvpn/plugunplug.conf &
