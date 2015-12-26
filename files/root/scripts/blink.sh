#!/bin/bash                                       

readonly SCRIPTS=/root/scripts
readonly SLEEP=/usr/bin/sleep
readonly GPIO=/sys/class/gpio/gpio9
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
            wink .05 .1 
            wink .05 .1
            wink .05 .1
            $SLEEP 10
        done                                            
}                                                       
                                                        
vpn() {                                          
    while true;                                     
        do                                          
            wink .05 .1 
            wink .05 .1
            $SLEEP 10
	    
        done      
}                              

idle() {
    while true;                                     
        do                                          
            wink .05 10
        done      
}
                                                    
killold() {
    PID=($(ps | grep [blin]k.sh | awk '{ print $1 }'))
    if [ ${#PID} -gt 1 ]; then
        kill -9 ${PID[0]}
    fi
}

case "$1" in                      
    *target*)                 
        killold
        echo "target" 
        target &      
    ;;                    
    *idle*)                  
        killold
        echo "idle"
        idle &
    ;;                    
    *vpn*)                  
        killold
        echo "vpnup"
        vpn &
    ;;                    
    *)                    
esac                          
