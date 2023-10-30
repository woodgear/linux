#!/bin/bash
echo "root:root" | chpasswd
apk update
apk add openrc
apk add util-linux
apk add ipvsadm
apk add curl
apk add dhcpcd
apk add dhcpcd-openrc
ln -s agetty /etc/init.d/agetty.ttyS0
echo ttyS0 > /etc/securetty
rc-update add agetty.ttyS0 default
rc-update add dhcpcd default
# Make sure special file systems are mounted on boot:
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot

# Then, copy the newly configured system to the rootfs image:
for d in bin etc lib root sbin usr; do tar c "/$d" | tar x -C /my-rootfs; done
for dir in dev proc run sys var; do mkdir /my-rootfs/${dir}; done

