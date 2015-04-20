#!/bin/bash

# Cyborg Unplug scan script for the TL-WR710. Scans for networks and writes out
# the important stuff for each all on one line.
#
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


DATA=/www/data/
SCAN=/tmp/scan
NETWORKS=$DATA/networks

#iw dev mon0 del
wifi down
uci set wireless.@wifi-iface[0].mode="monitor"
uci commit wireless
wifi

sleep 1 # important

NIC=$(iw dev | grep Interface | awk '{ print $2 }')
horst -q -i $NIC -f BEACON -o $SCAN -X scan &
HPID=$!
horst -x channel_auto=1
HPID2=$!
sleep 5
kill -9 $HPID $HPID2
cat $SCAN | awk '{ print $2 $4 $13 $15 }' | sort -u | sed 's/,$//' > $NETWORKS
cat $NETWORKS
