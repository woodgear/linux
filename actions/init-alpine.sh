#!/bin/bash
echo "root:root" | chpasswd
apk update
apk add openrc
apk add util-linux
apk add ipvsadm
apk add curl
apk add openssh
apk add dhcpcd
apk add dhcpcd-openrc
apk add rsyslog
apk add rsyslog-openrc

apk add vim iproute2 jq yq python3 bash iptables-legacy
### init
ln -s agetty /etc/init.d/agetty.ttyS0
echo ttyS0 >/etc/securetty

ssh-keygen -A
echo -e "PasswordAuthentication yes" >>/etc/ssh/sshd_config
echo -e "auto lo\niface lo inet loopback" >>/etc/network/interfaces

mkdir -p /root/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaz5oq/vU/+6wxAY4+qQsaFOhZCjt8EmAM5INh1EFfX wg@wg.com" >>/root/.ssh/authorized_keys

## auto start
rc-update add agetty.ttyS0 default
rc-update add networking default
rc-update add sshd default
rc-update add dhcpcd default
cp /e2e-tester.sh /etc/init.d/e2e-tester
chmod a+x /etc/init.d/e2e-tester
rc-update add e2e-tester default

# Make sure special file systems are mounted on boot:
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot
rc-update add rsyslog boot

# copy the newly configured system to the rootfs image:
for d in bin etc lib root sbin usr; do tar c "/$d" | tar x -C /my-rootfs; done
for dir in dev proc run sys var; do mkdir /my-rootfs/${dir}; done
