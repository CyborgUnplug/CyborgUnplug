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

readonly CONFIG=/www/config

cp /etc/config/wireless /www/config/ap
wifi down
uci set wireless.@wifi-iface[0].disabled="0"
uci set wireless.@wifi-iface[0].mode="sta"
uci set wireless.@wifi-iface[0].ssid="none"
uci set wireless.@wifi-iface[0].key="b0k1t0b0y"
wifi up

udhcp -i wlan0 -f
