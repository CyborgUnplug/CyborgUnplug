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
NIC=$(iw dev | grep Interface | awk '{ print $2 }')
TMPFILE=/tmp/scan.log
SCAN=$DATA/networks
S=1;E=3;

# Scrape 'iw' scan output and write to temporary file
iw dev $NIC scan | grep -E '^BSS|SSID|DS Parameter set: channel' | \
sed -e 's/BSS\ //' -e 's/(on.*$//' -e 's/DS Parameter\ set:\ channel\ // ' \
-e 's/SSID:\ //' > $TMPFILE && LEN=$(cat $TMPFILE | wc -l)

# Count lines in 3's
for i in $(seq 1 $((LEN/3)))
    do
        LINES=$(sed -n "$S,$E p;$E q" $TMPFILE)
        # Test for hidden ESSIDs. Allow for ESSIDs with spaces
        if [ $(echo $LINES | awk '{$1=$NF=""; print $0}' | sed -e 's/\ //' -e 's/$* //' | wc -c) -gt 1 ]; then 
                # Replace first and last whitespace with commas
                echo $LINES | sed -e 's/[[:space:]]/,/;s/\(.*\)[[:space:]]/\1,/' 
        fi	
        # Increment
            ((S+=3))
            ((E+=3))
    done > $SCAN
#iw dev $NIC scan | grep -e ^BSS -e SSID | cut -d " " -f 2 | sed -e '$!N;s/\n/,/' -e 's/(on//' > $DATA/networks
