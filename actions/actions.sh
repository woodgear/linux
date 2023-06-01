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

function lx-boot() {
  # -serial mon:stdio https://unix.stackexchange.com/a/436321
  # -nic user,model=e1000,hostfwd=tcp::2222-:22
  qemu-system-x86_64 \
    -kernel $PWD/arch/x86_64/boot/bzImage \
    -boot c \
    -m 2049M \
    -hda $PWD/rootfs.ext2 \
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial mon:stdio \
    -display none \
    -nic user,model=e1000,hostfwd=tcp::2222-:22

  return
}
