#!/bin/bash
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
readonly BINPATH=/usr/sbin/
readonly CONFIG=/www/config
readonly POLLTIME=10

while true;
	do
        #LOC=$(wget http://getcitydetails.geobytes.com/GetCityDetails?fqcn=123.45.67.8 -O - | awk -F'fqcn":"|","geobyteslatit' '{print $2}')
		p=$(ping -c 1 plugunplug.net|grep "1 packets received")
		if [[ ! -z $p ]]; then
            echo online > $CONFIG/networkstate
		else
			echo offline > $CONFIG/networkstate
		fi

		sleep $POLLTIME

	done
			
