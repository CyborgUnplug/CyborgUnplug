#!/bin/bash

DIR=cyborg-unplug
FW=cyborg-unplug-wr710n.bin

if [ ! -f $DIR ]; then
    mkdir $DIR
elif [ -f $DIR/$FW ]; then
    rm -f $DIR/$FW
fi
make image PACKAGES="kmod-fs-vfat kmod-fs-hfs kmod-fs-ext4 horst aircrack-ng lighttpd wireless-tools iw php5 php5-cgi php5-mod-curl libcurl curl gnupg bash screen lighttpd-mod-cgi coreutils coreutils-base64 openvpn-easy-rsa openvpn-openssl msmtp block-mount" PROFILE=TLWR710 FILES="files"
cp bin/ar71xx/openwrt-ar71xx-generic-tl-wr710n-v1-squashfs-sysupgrade.bin $DIR/$FW
