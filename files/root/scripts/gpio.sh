#!/bin/sh

#echo 9 > /sys/class/gpio/export
#echo out > /sys/class/gpio/gpio9/direction

led.sh

cd /sys/class/gpio
echo 9 > export
echo out > /sys/class/gpio/gpio9/direction
echo 0 > /sys/class/gpio/gpio9/value
# Reset button. Could never get it working in the DTS so we poll for it manually for now.
echo 10 > export
echo in > gpio10/direction

