#!/bin/bash

function lx-gen-cofnig() (
  #   make defconfig # 生成 .config文件
  # 1. ipvs 变成动态模块
  return
)

function lx-sync() (
  # init kernel module
  local ip=$1
  scp -r /lib/modules/5.13.0wg+ root@$ip:/lib/modules/
#   scp /usr/bin/curl-amd64-static root@$ip:/bin/curl
#   scp $PWD/http-echo root@$ip:/root/http-echo
  # ipvsadm
#   scp /usr/sbin/ipvsadm root@$ip:/bin/ipvsadm
#   scp /usr/lib/x86_64-linux-gnu/libpopt.so.0.0.1 root@$ip:/lib/libpopt.so.0
#   scp /usr/lib/x86_64-linux-gnu/libnl-3.so.200.26.0 root@$ip:/lib/libnl-3.so.200
#   scp /usr/lib/x86_64-linux-gnu/libnl-genl-3.so.200.26.0 root@$ip:/lib/libnl-genl-3.so.200
  return
)

function lx-build() (
  #   lx-gen-cofnig # 生成 .config文件 config已经生成好了 不能该
  set -e
  time make -j 10

  # 产出是bzimage
  md5sum ./arch/x86_64/boot/bzImage
  sudo rm -rf /lib/modules/5.13.0wg+/
  sudo mkdir /lib/modules/5.13.0wg+/
  sudo make modules_install
  sudo rm -rf /lib/modules/5.13.0wg+/build
  sudo rm -rf /lib/modules/5.13.0wg+/source
  return
)

function lx-readme() {
  #有两种debug的方式
  # 1. 重新编译一个bzimage,然后重启qemu 虚拟机
  # 2. 重新编译内核模块然后在linux中加载

  return
}

function lx-build-bzimage() {

  return
}

function lx-rootfs() {
  #用buildroot生成rootfs
  #
  return
}

function lx-ssh() {
  ssh -vvv root@127.0.0.1 -p 2222
}

function lx-note() {
  # e1000 1.21 Gbits/sec
  # virtio-net-pci
  # [ ID] Interval           Transfer     Bitrate         Retr
  # [  5]   0.00-10.00  sec  4.54 GBytes  3.90 Gbits/sec    0             sender
  # [  5]   0.00-9.96   sec  4.53 GBytes  3.91 Gbits/sec                  receiver
  # 要想使用 virtio-net-pci,必须要内核支持开启 CONFIG_VIRTIO_NET=y CONFIG_VIRTIO_PCI=y

  # 192.168.31.210 host (rip)
  # 192.168.122.76 vm
  # 192.168.122.10 vip

  # 122.1 -> 122.10
  # 122.1 -> 31.210

  return
}
function lx-boot() {
  # -serial mon:stdio https://unix.stackexchange.com/a/436321
  #     ctl-a c
  # -nic user,model=e1000,hostfwd=tcp::2222-:22
  #     在 /etc/network/interfaces
  #             auto eth0
  #             iface eth0 inet dhcp

  qemu-system-x86_64 \
    -kernel $PWD/arch/x86_64/boot/bzImage \
    -boot c \
    -m 2049M \
    -hda $PWD/rootfs.ext2 \
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial mon:stdio \
    -display none \
    -netdev bridge,id=hn0,br=virbr0 \
    -device e1000,netdev=hn0,id=nic1 # 注意device后的类型,如果想用 virtio-net-pci的话,必须要内核支持
  return
}
