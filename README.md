# CyborgUnplug

![](https://plugunplug.net/img/site-banner_gh.jpg)

![](https://plugunplug.net/img/home_v2.jpg)

Firmware files for _Little Snipper_. This firmware builds on OpenWrt BARRIER BREAKER (Bleeding Edge).

## ABOUT 'LITTLE SNIPPER'

Cyborg Unplug _Little Snipper_ is a privacy appliance for the home, hotel and workplace. It
detects and optionally disconnects (outside US only) selected devices known to
pose a risk to personal privacy, stopping streams of image, video and audio data
to the Internet (or the car outside).

Using a Virtual Private Network, this little plug also encrypts your Internet
traffic, locking out spies along the route. It can also be used to easily and
privately share files on a USB stick with others on the same network. No extra
software is required on your phone, tablet or laptop.

Visit the project page [here](http://plugunplug.net).

## BRANCH DIFFERENCES

Note the _wr710n_ (DIY) branch is far behind _master_ now and will be discontinued. This is due to TP-Link finally giving into the FCC and ensuring that this device can't be flashed with alternative, after-market firmware. We're currently looking into a new OpenWrt capable router target widely available in shops worldwide to support.

## KEYS

You may note that the branches have an /etc/shadow published here. The password is a dummy and will be ineffective in a physical attack on the device. For-sale devices are all given a unique /etc/shadow just prior to shipping.
More so, remote SSH attempts are not possible against shipped devices, which are blocked by a firewall for all WAN clients (including the Cyborg Unplug VPN admins!).
