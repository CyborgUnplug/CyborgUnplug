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
env > environment

# Remove each time script is invoked to disarm in case the user goes back
rm -f $CONFIG/armed

html() {
    echo Content-type: text/html
    echo
    echo '<html>'
    echo '<meta http-equiv="Refresh" content="1; url=/'"$1"'">'
    echo '</html>'
}

case "$EVENT" in
    *registered*)
        cp $SITE/index.php.conf $SITE/index.php
        html index.php
    ;;
    *encrypt*)
        if [ $(cat $CONFIG/vpnstatus) == "start" ]; then
            # Owner will only get here riding the back button after a failed/broken connection attempt
            # Reset config to 'unconfigured' 
            echo unconfigured > $CONFIG/vpnstatus
        fi
        if [ $(cat $CONFIG/vpnstatus) == "unconfigured" ]; then
            rm -f $UPLOAD/*
            html vpnconf.php
        else 
            html vpn.php
        fi
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
        cp $SITE/index.php.conf $SITE/index.php
        sleep 1
        html share.php
    ;; 
    *wlanrestart*)
        touch $CONFIG/setwifi
        html admin/wlanrestart.php
    ;; 
    *authrestart*)
        sed -i "s/:.*/:$(cat /tmp/config/adminpass)/" /root/keys/lighttpdpassword
        sleep 1
        rm -fr /tmp/config/adminpass
        /etc/init.d/lighttpd restart
        html admin/authrestart.php
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
		cat $DATA/networks > $CONFIG/networks
        html finish.php
	;;
	*mode4*)
		echo sweep > $CONFIG/mode
		cat $DATA/networks > $CONFIG/networks
        html finish.php
	;;
    *unplugvpn*)
        echo "0 plugunplug.ovpn" > $CONFIG/vpn
        echo start > $CONFIG/vpnstatus
        sleep 1
        html vpn.php
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
	*stopvpn*)
        echo stop > $CONFIG/vpnstatus
        sleep 3 # grace time for PID to exit fully 
        html vpn.php
	;;
	*newvpn*)
        echo unconfigured > $CONFIG/vpnstatus
        html vpnchoose.php
	;;
    *checkvpn*)
        html vpn.php #we need a full refresh to call the checking code in vpn.php
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
        killall openvpn vpn.sh # stop existing instance
        rm -f $CONFIG/vpn
		echo $EVENT > $CONFIG/event.log
		touch $CONFIG/armed	
		sleep 2
        html active.php
	;;
    *autoupdate*)
        update=$(echo "$EVENT" | cut -d '=' -f 2)
        if [[ "$update" == "disabled" ]]; then
            #comment out the update line in crontab
            sed -i '/update/ s/^/#/' /etc/crontabs/root
            echo disabled > $CONFIG/autoupdate
        elif [[ "$update" == "enabled" ]]; then
            #uncomment the update line in crontab
            sed -i '/^#.*update.*/ s/^#//' /etc/crontabs/root
            echo enabled > $CONFIG/autoupdate
        fi
        sleep 1
        html admin/updateconf.php 
    ;;
    *updatenow*)
        $SCRIPTS/update.sh 1 >> /dev/null &
        html admin/updatenow.php 
    ;;
	*)
esac
IFS=$OLDIFS
