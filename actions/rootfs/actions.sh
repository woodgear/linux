#!/bin/bash

function lx-rf-build() {
  rm ./rootfs.ext4
  dd if=/dev/zero of=rootfs.ext4 bs=1M count=50
  mkfs.ext4 rootfs.ext4
  md5sum ./rootfs.ext4
  rm -rf /tmp/my-rootfs
  mkdir /tmp/my-rootfs
  sudo mount rootfs.ext4 /tmp/my-rootfs
  docker run --rm  -v /lib/modules/5.13.0wg+/:/lib/modules/5.13.0wg+ -v $PWD/init-alpine.sh:/init-alpine.sh -v /tmp/my-rootfs:/my-rootfs alpine sh /init-alpine.sh
  sudo umount /tmp/my-rootfs
  md5sum ./rootfs.ext4
}
