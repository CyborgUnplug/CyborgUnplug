#!/bin/bash                                       

readonly SCRIPTS=/root/scripts
readonly SLEEP=/usr/bin/sleep
#readonly GPIO=/sys/class/gpio/gpio9
#echo 1 > $GPIO/value
echo 255 > /sys/class/leds/rt2800soc-phy0::radio/brightness

wink() {
    #echo 0 > $GPIO/value
    echo 0 > /sys/class/leds/rt2800soc-phy0::radio/brightness
    $SLEEP $1                             
    #echo 1 > $GPIO/value
    echo 255 > /sys/class/leds/rt2800soc-phy0::radio/brightness
    $SLEEP $2                             
}

target() {                                      
            wink 1 1 
}                                                       

reset() {                                      
            wink .05 .05
            wink .05 .05
            wink .05 .05
            wink .05 .05
            wink .05 .05
            $SLEEP 1
}                                                       

detect() {                                      
            wink .05 .1 
            wink .05 .1
            wink .05 .1
            $SLEEP 5
}                                                       
                                                        
vpn() {                                          
            wink .05 .1 
            wink .05 .1
            $SLEEP 5
}                              

idle() {
            wink .05 5
}
                                                    
while true;
	do read line;
        case "$line" in                      
            *target*)                 
                echo "target" 
                pattern=target 
                pid=$!
            ;;                    
            *detect*)                 
                echo "detect" 
                pattern=detect
                pid=$!
            ;;                    
            *reset*)                 
                echo "reset" 
                pattern=reset
                pid=$!
            ;;                    
            *idle*)                  
                echo "idle"
                pattern=idle
                pid=$!
            ;;                    
            *vpn*)                  
                echo "vpnup"
                pattern=vpn
                pid=$!
            ;;                    
            *stop*)
                kill -9 $pid 
            ;;
            *)                    
        esac            
	$pattern
   done < /tmp/blink
