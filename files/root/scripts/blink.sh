#!/bin/bash                                       

readonly SCRIPTS=/root/scripts
readonly SLEEP=/usr/bin/sleep
#readonly GPIO=/sys/class/gpio/gpio9
echo 1 > $GPIO/value

wink() {
    echo 0 > $GPIO/value
    $SLEEP $1                             
    echo 1 > $GPIO/value
    $SLEEP $2                             
}

target() {                                      
    while true;                             
        do  
            wink 1 1 
        done                                            
}                                                       

detect() {                                      
    while true;                             
        do  
            wink .05 .1 
            wink .05 .1
            wink .05 .1
            $SLEEP 5
        done                                            
}                                                       
                                                        
vpn() {                                          
    while true;                                     
        do                                          
            wink .05 .1 
            wink .05 .1
            $SLEEP 5
	    
        done      
}                              

idle() {
    while true;                                     
        do                                          
            wink .05 5
        done      
}
                                                    
killold() {
    PID=($(ps | grep [blin]k.sh | awk '{ print $1 }'))
    echo ${PID[@]}
    if [ ${#PID[@]} -gt 2 ]; then
        kill -9 ${PID[0]}
    fi
}

killold

case "$1" in                      
    *target*)                 
        echo "target" 
        target &      
    ;;                    
    *idle*)                  
        echo "idle"
        idle &
    ;;                    
    *vpn*)                  
        echo "vpnup"
        vpn &
    ;;                    
    *)                    
esac                          
