#!/bin/sh                                       
                                                
target() {                                      
        while true;                             
            do                                      
                echo 0 > /sys/class/gpio/gpio9/value
                sleep 1                             
                echo 1 > /sys/class/gpio/gpio9/value
                sleep 1                             
                echo 0 > /sys/class/gpio/gpio9/value
                sleep 1                             
                echo 1 > /sys/class/gpio/gpio9/value
                sleep 1                             
                echo 0 > /sys/class/gpio/gpio9/value
                sleep 1                             
                echo 1 > /sys/class/gpio/gpio9/value
                sleep 3
            done                                            
}                                                       
                                                        
default_on() {                                          
        while true;                                     
            do                                          
                    echo 0 > /sys/class/gpio/gpio9/value
                    sleep 2                             
                    echo 1 > /sys/class/gpio/gpio9/value
                    sleep 5
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
                                *)                    
                        esac                          
done < ledfifo  
