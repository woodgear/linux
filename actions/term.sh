#!/bin/bash
set -x

# -serial mon:stdio https://unix.stackexchange.com/a/436321
#     ctl-a c
# -nic user,model=e1000,hostfwd=tcp::2222-:22
#     在 /etc/network/interfaces
#     auto eth0
#     iface eth0 inet dhcp
sudo qemu-system-x86_64 \
  -kernel $PWD/arch/x86_64/boot/bzImage \
  -boot c \
  -m 2049M \
  -hda $PWD/rootfs.ext2 \
  -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
  -serial mon:stdio \
  -display none \
  -netdev bridge,id=hn0,br=virbr0 \
  -device virtio-net-pci,netdev=hn0,id=nic1
