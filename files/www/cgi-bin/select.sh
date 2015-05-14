#!/bin/bash

CONFIG=/www/config
DATA=/www/data

LINES=$(echo $1 | cut -d "=" -f 2 | sed 's/\ /\ \-e\ /g')
sed -n -e ${LINES} $DATA/devices > $CONFIG/targets
