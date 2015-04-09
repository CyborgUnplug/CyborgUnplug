# CyborgUnplug

Cyborg Unplug firmware for TP-Link WR710N
=================================================

Here are the files relevant to build the [Cyborg Unplug](https://plugunplug.net)
firmware for the TPLink WR710N (Atheros ar71xx). It is based on [OpenWrt](http://openwrt.org) and intended to be built using the OpenWrt Image
Builder. The target was the European 8Mb Flash model. It will not run on
anything smaller.

This is similar but not as polished as the firmware shipping on the sold rt5350f
_Little Snipper_ Cyborg Unplug model; intended for the more experienced
developer to play with and improve. It has less targets at the time of writing,
no smartphone notification system, no Tor transparent proxy and a disabled
update routine (easily enabled). These components/aspects will be refined for
the _Little Snipper_ and possibly folded back into this branch at a later date.

All of the code in root/scripts, www/cgi-bin was written by [Julian
Oliver](http://julianoliver.com) with the PHP (UI code) in www/ written by both
Julian Oliver and [Samim Winiger](http://samim.io).

BUILD
-----

(Tested on Debian GNU/Linux (Stable) only)

To build an image for the WR710N, you must first download the OpenWrt Image
Builder for the ar71xx target:

    http://wiki.openwrt.org/doc/howto/obtain.firmware.generate

Copy the _files_ directory and _build.sh_ script from this repo into the top
level of that tree and, ensuring you have a working Internet connection, run the
script like so:

    ~$ sh build.sh

If the stars are on your side, that should build, leaving you with the file
_cyborg-unplug-wr710n.bin_ in a folder _cyborg-unplug_ in your working
directory.

INSTALL
-------

Start up your TP-Link WR710N and connect to it. Visit the administration page
and in the advanced settings select 'upgrade firmware'. Browse to the file
_cyborg-unplug_ , let it flash and once done, it should reboot.

If anything goes hideously wrong, see the unbricking guide on this page. At the
worst you'll need a soldering iron and a USB serial FTDI:

    http://wiki.openwrt.org/toh/tp-link/tl-wr710n

USE
---

Once it has rebooted pick up a smartphone, tablet or laptop and look for a
network beginning with the word _unplug_, followed with 6 alphanumeric
characters. Those last 6 characters match the last six of the device's MAC
address - helpful when identifying one Unplug among many. 

Connect to the network using the (deliberately unimaginative) password:
    
    l1ttl35n1pp3r

You will be granted an IP in the 10.10.10.0-255 range. Either type
'littlesnipper' or 'http://10.10.10.1' in the URL bar of your browser to be
taken to the configuration page.







