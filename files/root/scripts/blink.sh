#!/bin/sh                                       

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
            wink 1 1
            wink 1  1                                  
            $SLEEP 3
        done                                            
}                                                       
                                                        
idle() {                                          
    while true;                                     
        do                                          
            wink .1 .25 
            wink .1 .25
            $SLEEP 1
	    
        done      
}                              

vpn() {
    while true;                                     
        do                                          
            wink .1 3
            wink .1 3
            wink .1 3
            $SLEEP 3                             
        done      
}
                                                    
killold() {
    PID=$(ps | grep [blin]k.sh | awk '{ print $1 }' | head -n 1)
    kill -9 $PID
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
