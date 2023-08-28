#!/bin/bash

# -serial mon:stdio https://unix.stackexchange.com/a/436321
#     ctl-a c
#     在 /etc/network/interfaces
#     auto eth0
#     iface eth0 inet dhcp
# cp ./rootfs2.ext2.boot-eth0 ./rootfs2.ext2
# md5sum ./rootfs2.ext2
# md5sum ./rootfs2.ext2.boot-eth0

sudo qemu-system-x86_64 \
  -kernel $PWD/arch/x86_64/boot/bzImage \
  -enable-kvm \
  -cpu host \
  -smp 2 \
  -boot c \
  -m 2049M \
  -hda $PWD/rootfs2.ext2 \
  -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
  -serial mon:stdio \
  -monitor telnet::5551,server,nowait \
  -serial telnet::5552,server,nowait \
  -serial telnet::5553,server,nowait \
  -serial telnet::5554,server,nowait \
  -serial telnet::5555,server,nowait \
  -display none \
  -netdev bridge,id=hn0,br=virbr0 \
  -device virtio-net-pci,netdev=hn0,id=nic1,mac=52:54:00:12:34:f2