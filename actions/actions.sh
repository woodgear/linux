#!/bin/bash

export LX_BASE=$PWD

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

function lx-unit() (
  ./tools/testing/kunit/kunit.py run
)

function lx-build-and-test() (
  lx-build
  lx-mount-module
  lx-test
)

function lx-build() (
  #   lx-gen-cofnig # 生成 .config文件 config已经生成好了
  set -ex
  local start=$(date)
  cp ./.config.cong ./.config
  time make -j 10

  # 产出是bzimage
  #   rm  ./arch/x86_64/boot/bzImage
  sudo make modules_install

  local end=$(date)
  echo "start: $start"
  echo "end: $end"
  return
)

function lx-mount-module() (
  sudo mount rootfs.ext4 /tmp/my-rootfs
  sudo mkdir /tmp/my-rootfs/lib/modules
  sudo cp -r /lib/modules/5.13.0wg+ /tmp/my-rootfs/lib/modules
  sudo umount /tmp/my-rootfs || true
)

function lx-mount-test() (
  set -ex
  sudo mount $LX_BASE/actions/rootfs.ext4 /tmp/my-rootfs
  sudo rm -rf /tmp/my-rootfs/tests || true
  sudo mkdir -p /tmp/my-rootfs/tests
  sudo cp -r $LX_BASE/actions/tests/* /tmp/my-rootfs/tests/
  sudo umount /tmp/my-rootfs || true
)

function lx-rf-build() (
  set -xe
  cd $PWD/actions
  rm ./rootfs.ext4 || true
  dd if=/dev/zero of=rootfs.ext4 bs=1G count=3
  mkfs.ext4 rootfs.ext4
  #   md5sum ./rootfs.ext4
  sudo umount /tmp/my-rootfs || true
  sudo rm -rf /tmp/my-rootfs || true
  mkdir /tmp/my-rootfs
  sudo mount rootfs.ext4 /tmp/my-rootfs
  echo "build rootfs via docker"
  # 理论上build的时候不需要挂载模块，因为正常来讲用户态的东西不会因为内核模块的变化而变化
  docker run --network host --rm -v $PWD/init-alpine.sh:/init-alpine.sh -v $PWD/e2e-tester.sh:/e2e-tester.sh -v /tmp/my-rootfs:/my-rootfs alpine sh /init-alpine.sh
  sudo umount /tmp/my-rootfs

  lx-mount-module
  lx-mount-test
  #   md5sum ./rootfs.ext4
)

function lx-shell() {
  touch $LX_BASE/actions/tests/not-test
  touch $LX_BASE/actions/tests/not-stop
  lx-mount-test
  rm $LX_BASE/actions/tests/not-test || true
  rm $LX_BASE/actions/tests/not-stop || true

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
}

function lx-cat-rf() {
  sudo mount $LX_BASE/actions/rootfs.ext4 /tmp/my-rootfs
  sudo cat /tmp/my-rootfs/$1
  sudo umount /tmp/my-rootfs
}

function lx-test() {
  local start=$(date)
  rm $LX_BASE/actions/tests/not-test || true
  rm $LX_BASE/actions/tests/no-stop || true
  lx-mount-test
  qemu-system-x86_64 \
    -kernel $PWD/arch/x86_64/boot/bzImage \
    -boot c \
    -m 2049M \
    -hda $PWD/actions/rootfs.ext4 \
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial mon:stdio \
    -display none \
    -netdev bridge,id=hn0,br=virbr0 \
    -device e1000,netdev=hn0,id=nic1 \
    -no-reboot

  echo "============="
  lx-cat-rf /tests/test.log
  local end=$(date)
  echo "start: $start"
  echo "end: $end"
  return
}

function lx-readme() {
  #有两种debug的方式
  # 1. 重新编译一个bzimage,然后重启qemu 虚拟机
  # 2. 重新编译内核模块然后在linux中加载

  # 1. lx-build -> build 一个bzimage # 内核的改动在这里
  # 2. lx-rf-build -> build 一个rootfs
  # 3. lx-mount-module -> 将内核模块挂在到rootfs中 # 模块里的改动在这里
  # 4. lx-boot -> 启动qemu虚拟机

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

function lx-init-fs() {
  return
}

function lx-show-log() {
  # 注意必须是单行的
  # ^ 行首
  # (\s*) 任意空格
  # (\/\/)? 有可能已经被注释了
  # (\s*) 任意空格
  # ([^\s]*.*\[wg\].*;)
  #  [^\s]*不为空格的字符
  #  .* 任意字符
  #  ; 分号
  rg --line-number --no-heading -g '*.c' "^(\s*)(\/\/)?(\s*)([^\s]*.*\[wg\].*;)\s*$" -r '$1 $2' ./
}

function pcall() {
  ./actions/pcall.py $@
}

function lx-modify-all-log() {
  local seq="@@@@"
  local prefix="$1"
  rg --line-number --no-heading -g '*.c' "\[wg\]" ./
  rm ./.replaces
  touch ./.replaces

  while read -r line; do
    # echo -E "$line"
    local file_and_line=$(echo -E "$line" | awk -F "$seq" '{print $1}')
    local file=$(echo -E "$file_and_line" | awk -F ":" '{print $1}')
    local line_number=$(echo -E "$file_and_line" | awk -F ":" '{print $2}')
    local code=$(echo -E "$line" | awk -F "$seq" '{print $2}')
    echo -E "$code"
    echo -E "${file}${seq}${line_number}${seq}${prefix}${code}" >>./.replaces
  done < <(rg --line-number --no-heading -g '*.c' "^(//)?(\s*[^\s]*.*\[wg\].*;)\s*$" -r "$seq\$2" ./ | cat)
  pcall replace-line ./.replaces $seq
}

function lx-enable-all-log() {
  lx-modify-all-log ""
}

function lx-disable-all-log() {
  lx-modify-all-log "//"
}
