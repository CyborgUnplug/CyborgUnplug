#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/LITTLESNIPPER
	NAME:=Cyborg Unplug Little Snipper
	PACKAGES:=kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-ledtrig-usbdev \
		kmod-i2c-core kmod-i2c-gpio
endef

define Profile/LITTLESNIPPER/Description
	Package set for Cyborg Unplug Little Snipper Board
endef

$(eval $(call Profile,LITTLESNIPPER))
