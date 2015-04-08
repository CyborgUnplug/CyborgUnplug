mkdir cyborg-unplug
make image PACKAGES="aircrack-ng lighttpd wireless-tools iw php5 php5-cgi gnupg bash screen lighttpd-mod-cgi coreutils coreutils-base64" PROFILE=TLWR710 FILES="files"
cp bin/ar71xx/openwrt-ar71xx-generic-tl-wr710n-v1-squashfs-sysupgrade.bin cyborg-unplug/cyborg-unplug-wr710n.bin
