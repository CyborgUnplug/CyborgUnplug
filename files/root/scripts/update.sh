#!/bin/bash
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

TMPDIR=/tmp
WWWDIR=/www
BUPDIR=/root/backup
RANGE=300
FULLDATE=$(date +%Y-%m-%d_%H-%M-%S)
number=$RANDOM
let "number %= $RANGE"
#sleep $number
echo sleeping for $number
rm -f update-daily.tar.gz
echo "Retreiving update package"
wget http://dislocative.com/unplug/update/update-daily.tar.gz -P $TMPDIR 
echo "Downloading signature"
wget http://dislocative.com/unplug/update/update-daily.tar.gz.gpg 
echo "verifying..."
CHECKSIG=$(gpg --status-fd 1 --verify update-daily.tar.gz.gpg update-daily.tar.gz | grep -o VALIDSIG)
if [[ "$CHECKSIG" == VALIDSIG ]]
	then
		echo "Appears to be a trustworthy archive. Backing up existing config..."	
		touch $WWWDIR/config/updated
        echo "Backing up existing files..."
        tar cvzf $BUPDIR/$FULLDATE.tar.gz /etc /root/scripts /www
		echo "Extracting archive..."
		tar xvzf update-daily.tar.gz -C $TMPDIR
        reboot
fi
