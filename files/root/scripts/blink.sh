#!/bin/sh                                       
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

SLEEP=/usr/bin/sleep
echo 1 > /sys/class/gpio/gpio9/value

$SLEEP 1

wink() {
    echo 0 > /sys/class/gpio/gpio9/value
    $SLEEP $1                             
    echo 1 > /sys/class/gpio/gpio9/value
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
done < ledfifo  
