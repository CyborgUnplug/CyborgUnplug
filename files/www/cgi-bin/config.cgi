#!/bin/bash

# Cyborg Unplug CGI script for the TL-WR710. Takes 'events' from the PHP based
# interface, parses it and writes configuration files used by the detection
# routine. 
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

ROOT=/www
DATA=$ROOT/data
CONFIG=$ROOT/config
EVENT=$(echo $QUERY_STRING | sed 's/\+/\ /g')
OLDIFS=$IFS
IFS="&"
set $EVENT
echo $EVENT > event.log 
env > environment

# Remove each time script is invoked to disarm in case the user goes back
rm -f $CONFIG/armed

case "$EVENT" in
	*devices*)
		echo $EVENT > /tmp/foo
		echo $EVENT | cut -d "=" -f 2 | sed -e 's/%3D/=/g' -e 's/\ //g' | base64 -d | sed 's/^\ //' > $CONFIG/targets
		echo Content-type: text/html
		echo
		echo "<html>"
		echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/mode.php">'
		echo '</html>'
	;;
	*mode1*)
		echo territory > $CONFIG/mode
		echo Content-type: text/html
		echo
		echo "<html>"
		echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/territorial.php">'
		echo '</html>'
	;;
	*mode2*)
		echo allout > $CONFIG/mode
		echo Content-type: text/html
		echo
		echo "<html>"
		echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/allout.php">'
		echo '</html>'
	;;
	*mode3*)
		echo alarm > $CONFIG/mode
		echo Content-type: text/html
		echo
		echo "<html>"
		echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/allout.php">'
		echo '</html>'
	;;
	*finish1*)
		echo $EVENT | cut -d "=" -f 2 | sed -e 's/%3D/=/g' -e 's/\ //g' | base64 -d  > $CONFIG/networks
		echo Content-type: text/html
		echo
		echo "<html>"
		echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/finish.php">'
		echo '</html>'
	;;
	*finish2*)
		cat $DATA/networks > $CONFIG/networks
        echo Content-type: text/html
        echo
        echo "<html>"
        echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/finish.php">'
        echo '</html>'	
	;;
	*armed*)
		echo $EVENT > $CONFIG/event.log
		touch $CONFIG/armed	
		sleep 2
		echo '<html>'
		echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/active.php">'
		echo '</html>'
			
	;;
	*)
esac
IFS=$OLDIFS
