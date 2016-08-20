#!/bin/bash

# Cyborg Unplug reset watchdog for RT5350f LittleSnipper. 
# Couldn't get the reset working in the DTS for this board, to have this done in the kernel.
# So, here we are polling the GPIO manually every single second this device is powered. 
# A bit fugly, the fugliest on this device, but all I have for now. 
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

readonly SCRIPTS=/root/scripts
readonly RESETPIN=/sys/class/gpio/gpio10/
readonly RESETDIR=/root/reset

count=0

while true;
    do
        read pressed < $RESETPIN/value
        if [[ $pressed -eq 0 ]]; then
            let 'count+=1'
            echo $count
            if [[ $count -gt 10 ]]; then
                echo "resetting"
		rm -f /www/config/since
		rm -f /www/config/email
                mkdir $RESETDIR/fs
                tar xvzf /usr/share/reset/reset.tar.gz -C $RESETDIR/fs 
                touch $RESETDIR/resetnow
                # count=0
                echo reset > /tmp/blink
                sleep 3 # let the owner see the reset blink pattern 
                /sbin/reboot
            fi
        fi
    sleep 1
done 
