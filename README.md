# CyborgUnplug

Cyborg Unplug firmware for TP-Link WR710N
=================================================

Here are the files relevant to build the [Cyborg Unplug](https://plugunplug.net)
firmware for the TPLink WR710N (Atheros ar71xx). It is based on
[OpenWrt](http://openwrt.org) and intended to be built using the OpenWrt Image
Builder. The target was the European 8Mb Flash model. It will not run on
anything smaller. 

![](https://github.com/JulianOliver/CyborgUnplug/blob/wr710n/images/wr710n.jpg)

If you don't want to build, just [grab the
firmware](https://github.com/JulianOliver/CyborgUnplug/blob/wr710n/bin/cyborg-unplug-wr710n.bin)
and flash it on right away.

This release is similar but not as polished as the firmware shipping on the
for-sale rt5350f [Little Snipper](https://plugunplug.net/) Cyborg Unplug
model; intended for the more experienced developer to play with and improve. It
has no notification system (requiring an SMTP mail relay host that I can't
provide for everyone), no free VPN service (bandwidth costs would be huge) and
has a disabled update routine (use the firmware posted here, instead). 

All code is made available here under the [General Public
License](https://www.gnu.org/copyleft/gpl.html) (Version 3 or later).

The *files/etc* has been included as it contains many original OpenWrt files
modified to get things working. It was easier just to throw in the whole dir.

ABOUT CYBORG UNPLUG
------------------

Cyborg Unplug is a privacy appliance for the home, hotel and workplace. It
detects and optionally disconnects (outside US only) selected devices known to
pose a risk to personal privacy, stopping streams of image, video and audio data
to the Internet (or the car outside). 

Using a Virtual Private Network, this little plug also encrypts your Internet
traffic, locking out spies along the route. It can also be used to easily and
privately share files on a USB stick with others on the same network. No extra
software is required on your phone, tablet or laptop.

Visit the project page [here](https://plugunplug.net).

BUILD
-----

(Tested on Debian GNU/Linux (Stable) only)

To build an image for the WR710N, you must first download the OpenWrt Image
Builder for the ar71xx target:

    http://wiki.openwrt.org/doc/howto/obtain.firmware.generate

Copy the *files* directory and *build.sh* script from this repo into the top
level of that tree and, ensuring you have a working Internet connection, run the
script like so:

    ~$ sh build.sh

If the stars are on your side, that should build, leaving you with the file
*cyborg-unplug-wr710n.bin* in a folder *cyborg-unplug* in your working
directory.

INSTALL
-------

Start up your TP-Link WR710N and connect to it. Visit the administration page
and in the advanced settings select 'upgrade firmware'. Browse to the file
*cyborg-unplug-wr710n.bin* , let it flash and once done, it should reboot.

If anything goes hideously wrong, see the unbricking guide on this page. At the
worst you'll need a soldering iron and a USB serial FTDI:

    http://wiki.openwrt.org/toh/tp-link/tl-wr710n

USE
---

Once it has rebooted pick up a smartphone, tablet or laptop and look for a
network beginning with the word _unplug_, followed by 4 alphanumeric characters.
Those last 4 characters match the last four of the device's MAC address -
helpful when identifying one Unplug among many. 

Connect to the network using the (deliberately unimaginative) password:
    
    l1ttl35n1pp3r

You will be granted an IP in the 10.10.10.0-255 range. Either type
_littlesnipper_ or _http://10.10.10.1_ in the URL bar of your browser to be
taken to the configuration page.

NOTE: If no configuration is done using the browser interface, the Unplug
defaults to being a nice little wireless router - just plug it into a router
with a gateway to the Internet (with an Ethernet cable on the WAN port) and
you're good to go.

CONFIGURE
---------

To change passwords (recommended), log in over ssh on port 3030 like so:

    ssh -p 3030 root@10.10.10.1
   
Password is:

    l1ttl35n1pp3r

You'll see:

    BusyBox v1.22.1 (2014-07-17 06:45:57 PDT) built-in shell (ash)
    Enter 'help' for a list of built-in commands.

                __                                  __         
      ______ __/ /  ___  _______ _  __ _____  ___  / /_ _____ _
     / __/ // / _ \/ _ \/ __/ _ `/ / // / _ \/ _ \/ / // / _ `/
     \__/\_, /_.__/\___/_/  \_, /  \_,_/_//_/ .__/_/\_,_/\_, / 
        /___/              /___/           /_/          /___/ 
     
     ----------------------------------------------------------
     Built on OpenWrt BARRIER BREAKER (Bleeding Edge) 
     ----------------------------------------------------------
     http://plugunplug.net
     http://openwrt.org
     ----------------------------------------------------------

Now change your root password by typing the following, providing a new one in
turn:

    passwd

To change the WiFi key, ESSID and Channel, connect to the device with your
phone/tablet/laptop and visit the _configure_ menu in the home screen.

Alternatively, you can ssh in and:

    uci set wireless.@wifi-iface[0].key="yourKeyH3r3"
    uci set wireless.@wifi-iface[0].SSID="AnotherESSID"
    uci set wireless.@wifi-iface[0].channel=8
    uci commit
    exit & reboot -n

NOTE: If you log in over Ethernet cable, type _wifi_ in place of _exit &
reboot -n_.

