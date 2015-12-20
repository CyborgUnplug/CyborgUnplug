#!/bin/bash

# Cyborg Unplug CGI script for the RT5350f. Takes an 'event' from the PHP
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

readonly SITE=/www
readonly DATA=$SITE/data
readonly CONFIG=$SITE/config
readonly EVENT=$(echo $QUERY_STRING | sed 's/\+/\ /g')
readonly OLDIFS=$IFS
readonly SCRIPTS=/root/scripts
readonly IFS="&"
readonly UPLOAD=/tmp/keys

set $EVENT
#EVENT=${EVENT/=*/} 
#echo $EVENT > event.log 
env > environment

# Remove each time script is invoked to disarm in case the user goes back
rm -f $CONFIG/armed

html() {
    echo Content-type: text/html
    echo
    echo '<html>'
    echo '<meta http-equiv="Refresh" content="1; url=http://10.10.10.1/'"$1"'">'
    echo '</html>'
}

case "$EVENT" in
    *detect*)
        html detect.php
    ;; 
    *encrypt*)
        if [ $(cat $CONFIG/vpnstatus) == "unconfigured" ]; then
            rm -f $UPLOAD/*
            html vpnchoose.php
        elif [ -f $CONFIG/vpn ]; then
            html vpn.php
        fi
    ;; 
    *share)
        html share.php
    ;; 
    *sharerefresh*)
        block umount
        block mount
        sleep 1
        html share.php
    ;; 
    *sharelock*)
        cp $SITE/share-visits.php $SITE/index.php
        sleep 1
        html index.php
    ;; 
    *umount*)
        block umount
        sleep 1
        html share.php
    ;; 
    *configure*)
        html configure.php
    ;; 
    *wifi*)
        html wlanconf.php
    ;;
    *wlanrestart*)
        touch $CONFIG/setwifi
        html wlanrestart.php
    ;; 
	*devices*)
		echo $EVENT | cut -d "=" -f 2 | sed -e 's/%3D/=/g' -e 's/\ //g' | base64 -d | sed 's/^\ //' > $CONFIG/targets
        html mode.php
	;;
	*mode1*)
		echo territory > $CONFIG/mode
        html territorial.php
	;;
	*mode2*)
		echo allout > $CONFIG/mode
        html allout.php
	;;
	*mode3*)
		echo alarm > $CONFIG/mode
        html allout.php
	;;
    *unplugvpn*)
        echo "0 plugunplug.ovpn" > $CONFIG/vpn
        echo start > $CONFIG/vpnstatus
        sleep 1
        html vpn.php
    ;;    
    *vpnconf*)
        html vpnconf.php
    ;;
	*extvpn*)
        readonly vpnargs=$(echo $EVENT | cut -d "=" -f 2 | sed -e 's/%3D/=/g' | base64 -d)
        echo $vpnargs > $CONFIG/vpn
        echo start > $CONFIG/vpnstatus
	# check it's wise to have uploads in tmp
        chmod go-rw $UPLOAD/* 
        sleep 1
        html vpn.php
	;;
	*checkvpn*)
        html vpn.php
	;;
	*stopvpn*)
        echo stop > $CONFIG/vpnstatus
        sleep 3 # grace time for PID to exit fully 
        html vpnconf.php
	;;
	*newvpn*)
        echo unconfigured > $CONFIG/vpnstatus
        html vpnchoose.php
	;;
	*finish1*)
		echo $EVENT | cut -d "=" -f 2 | sed -e 's/%3D/=/g' -e 's/\ //g' | base64 -d  > $CONFIG/networks
        html finish.php
	;;
	*finish2*)
		cat $DATA/networks > $CONFIG/networks
        html finish.php
	;;
	*armed*)
        echo "plugunplug.ovpn 0" > $CONFIG/vpn
        echo start > $CONFIG/vpnstatus
		echo $EVENT > $CONFIG/event.log
		touch $CONFIG/armed	
		sleep 2
        html active.php
	;;
	*)
esac
IFS=$OLDIFS
