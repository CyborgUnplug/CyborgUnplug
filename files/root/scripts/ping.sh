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
        # We call php-cgi here as /usr/bin/curl doesn't support SSL while PHP's
        # curl implementation does
        loc=$(php-cgi /www/admin/curl.php | tr -d $'\r' | tail -n +3 | head -n 1)
		if [[ ! -z $loc ]]; then
            echo online $loc > $CONFIG/networkstate
		else
			echo offline > $CONFIG/networkstate
		fi

		sleep $POLLTIME

	done
			
