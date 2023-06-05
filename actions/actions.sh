#!/bin/bash

function lx-build() {
  make defconfig # 生成 .config文件
  make
  return
}

function lx-rootfs() {
  #用buildroot生成rootfs
  return
}

function lx-ssh() {
  ssh -vvv root@127.0.0.1 -p 2222
}

function lx-boot() {
  # -serial mon:stdio https://unix.stackexchange.com/a/436321
  #     ctl-a c
  # -nic user,model=e1000,hostfwd=tcp::2222-:22
  #     在 /etc/network/interfaces 
  #         
  qemu-system-x86_64 \
    -kernel $PWD/arch/x86_64/boot/bzImage \
    -boot c \
    -m 2049M \
    -hda $PWD/rootfs.ext2 \
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial mon:stdio \
    -display none \
    -nic user,hostfwd=tcp::2222-:22

  return
}
