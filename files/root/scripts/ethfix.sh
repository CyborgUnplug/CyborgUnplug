#!/bin/bash

CONFIG=/www/config/

sleep 10

if [ ! -f $CONFIG/mac ]; then

    RANGE=255
    NUM=$RANDOM
    NUMA=$RANDOM
    NUMB=$RANDOM

    let "NUM %= $RANGE"
    let "NUMA %= $RANGE"
    let "NUMB %= $RANGE"

    VENDOR='00:1F:1F'

    A=`echo "obase=16;$NUM" | bc`
    B=`echo "obase=16;$NUMA" | bc`
    C=`echo "obase=16;$NUMB" | bc`

    MAC="${VENDOR}:${A}:${B}:${C}"
    echo $MAC > $CONFIG/mac

fi

ifconfig eth0 hw ether $(cat $CONFIG/mac)
ifconfig eth0 up
ifconfig eth0 > ran
/etc/init.d/dnsmasq restart
