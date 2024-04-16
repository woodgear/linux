#!/bin/bash

function lx-build() (
  #   lx-gen-cofnig # 生成 .config文件 config已经生成好了 不能该
  set -ex
  local start=$(date)
  cp ./.config.cong ./.config
  time make -j 10

  # 产出是bzimage
  md5sum ./arch/x86_64/boot/bzImage
  sudo rm -rf /lib/modules/3.10.0wg+/
  sudo mkdir /lib/modules/3.10.0wg+/
  sudo make modules_install
  sudo rm -rf /lib/modules/3.10.0wg+/build
  sudo rm -rf /lib/modules/3.10.0wg+/source

  local end=$(date)
  echo "start: $start"
  echo "end: $end"
  return
)

function lx-boot() {
  qemu-system-x86_64 \
    -kernel $PWD/arch/x86_64/boot/bzImage \
    -boot c \
    -m 2049M \
    -hda $PWD/actions/rootfs.ext4 \
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial mon:stdio \
    -display none \
    -netdev bridge,id=hn0,br=virbr0 \
    -device e1000,netdev=hn0,id=nic1
  return
}