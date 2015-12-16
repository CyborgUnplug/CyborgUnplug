#!/bin/sh                                       

readonly SCRIPTS=/root/scripts
readonly SLEEP=/usr/bin/sleep
readonly GPIO=/sys/class/gpio/gpio9
echo 1 > $GPIO/value

$SLEEP 1

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
                                                        
default_on() {                                          
    while true;                                     
        do                                          
            wink .1 .25 
            wink .1 .25
            $SLEEP 1
	    
        done      
}                              

vpnup() {
    while true;                                     
        do                                          
            wink .1 3
            wink .1 3
            wink .1 3
            $SLEEP 3                             
        done      
}

default_on &
PID=$!        
                                                    
while true;                                          
do                                                   
    read line;                                   
        case "$line" in                      
            *1*)                 
                kill -9 $PID 
                echo "target" 
                target &      
                PID=$!        
            ;;                    
            *2*)                  
                kill -9 $PID  
                echo "default"
                default_on &
                PID=$!
            ;;                    
            *3*)                  
                kill -9 $PID  
                echo "vpnup"
                vpnup &
                PID=$!
            ;;                    
            *)                    
        esac                          
done < $SCRIPTS/ledfifo  
