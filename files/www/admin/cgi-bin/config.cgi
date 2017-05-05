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

readonly SITE=/www/admin/
readonly DATA=$SITE/data
readonly CONFIG=$SITE/config
readonly EVENT=$(echo $QUERY_STRING | sed 's/\+/\ /g')
readonly OLDIFS=$IFS
readonly SCRIPTS=/root/scripts
readonly IFS="&"
readonly UPLOAD=/tmp/keys
readonly KEYS=/root/keys

set $EVENT
#EVENT=${EVENT/=*/} 
env > environment

# Remove each time script is invoked to disarm in case the user goes back
rm -f $CONFIG/armed

html() {
    echo Content-type: text/html
    echo
    echo '<html>'
    echo '<meta http-equiv="Refresh" content="1; url=/'"admin/$1"'">'
    echo '</html>'
}

echo $EVENT > $CONFIG/event.log

case "$EVENT" in
    *registered*)
        cp $SITE/index.php.conf $SITE/index.php
        html index.php
    ;;
    *protect*)
        if [ $(cat $CONFIG/vpnstatus) == "start" ]; then
            # Owner will only get here riding the back button after a failed/broken connection attempt
            # Reset config to 'unconfigured' 
            echo unconfigured > $CONFIG/vpnstatus
        fi
        if [ $(cat $CONFIG/vpnstatus) == "unconfigured" ]; then
            rm -f $UPLOAD/*
            html vpnchoose.php
        else 
            html vpn.php
        fi
    ;; 
    # This event probably no longer needed as it's all handled by /www/share/cgi-bin/config.cgi now
    *umount*)
        block umount
        cp $SITE/index.php.conf $SITE/index.php
        sleep 1
        html index.php 
    ;; 
    *wlanrestart*)
        touch $CONFIG/setwifi
        html wlanrestart.php
    ;; 
    *authrestart*)
        echo "admin:"$(cat /tmp/config/adminpass) > /root/keys/lighttpdpassword
        #sed -i "s/:.*/:$(cat /tmp/config/adminpass)/" /root/keys/lighttpdpassword
        sleep 1
        rm -f /tmp/config/adminpass
        html index.php 
    ;; 
	*devices*)
		#echo $EVENT | cut -d "=" -f 2 | sed -e 's/%3D/=/g' -e 's/\ //g' | base64 -d | sed 's/^\ //' > $CONFIG/targets
        echo ${EVENT##*devices=} | sed -e 's/%3D/=/g' -e 's/\ //g' -e 's/selectall//' | base64 -d | sed 's/^\ //' > $CONFIG/targets 
        html mode.php
	;;
	*mode1*)
		echo alarm > $CONFIG/mode
		cat $DATA/networks > $CONFIG/networks
        html finish.php
	;;
	*mode2*)
		echo sweep > $CONFIG/mode
        $SCRIPTS/wifi.sh scan
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
    *savevpn*)
        cp $CONFIG/vpn $CONFIG/savedvpn
        #sed -i 's/$/\ saved\ /' $CONFIG/vpn
        ovpn=$(cat $CONFIG/vpn | cut -d ' ' -f 2)
        if [[ $ovpn != "plugunplug.ovpn" ]]; then 
            cp $UPLOAD/$ovpn* $KEYS/ #copy auth file also
        fi  
        html vpn.php
    ;;
    *removevpn*)
        # Remove the VPN we have set to use on startup 
        ovpn=$(cat $CONFIG/vpn | cut -d ' ' -f 2)
        if [[ $ovpn != "plugunplug.ovpn" ]]; then 
            rm -f $KEYS/$ovpn* #remove .ovpn files and auth file, if present
        fi  
        rm -f $CONFIG/savedvpn
        html vpn.php
    ;;
    *bridgechoose*)
        $SCRIPTS/wifi.sh scan 
        html bridge.php
    ;;
    *bridgeset*)
        touch $CONFIG/bridgeset
        html index.php
    ;;
    *savedbridge*)
        # copy our saved bridge data to the bridge file for use this turn
        touch $CONFIG/bridgeset
        cp $CONFIG/savedbridge $CONFIG/bridge 
        html index.php 
    ;;
    *removebridge*)
        # Toggle a value in $CONFIG/savedbridge so that it is no longer used on startup 
        sed -i 's/1$/0/' $CONFIG/savedbridge
        html bridge.php
    ;;
	*armed*)
        #killall openvpn vpn.sh # stop existing instance
        #rm -f $CONFIG/vpn
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
        html updateconf.php 
    ;;
    *updatenow*)
        $SCRIPTS/update.sh 1 >> /dev/null &
        html updatenow.php 
    ;;
    *reboot*)
        reboot -n
        html rebooting.php 
    ;;
	*)
esac
IFS=$OLDIFS
