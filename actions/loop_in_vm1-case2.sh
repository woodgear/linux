#!/bin/sh
# echo "1. 没有vip 2. rip是本机 3. 有ipvs规则 4. 有iptable规则"
# vm1 当leader
# debug 单节点vip问题

vm1=192.168.122.231
vm2=192.168.122.232
vip=192.168.122.10
out=192.168.31.210

update_ipvs_mod() {
  rmmod ip_vs_rr
  rmmod ip_vs
  modprobe ip_vs
}

clean() {
  ip address del 192.168.121.100/32 dev eth0 || true
  ipvsadm -D -t 192.168.122.10:3333 || true
  rmmod ip_vs_rr
  rmmod ip_vs
}

init_iptable() {
  iptables-save | grep -v cong | iptables-restore
  iptables -t nat -A POSTROUTING -j MASQUERADE -d "$vm1/32" -m comment --comment "cong"
  iptables -t nat -A POSTROUTING -j MASQUERADE -d "$vm2/32" -m comment --comment "cong"
  iptables -t nat -A POSTROUTING -j MASQUERADE -d "$out/32" -m comment --comment "cong"
}

init_ip() {
  ip address add 192.168.122.10 dev eth0
}

init_sysctl() {
  sysctl -w net.ipv4.ip_forward=1
  sysctl -w net.ipv4.conf.all.arp_accept=1
  sysctl -w net.ipv4.vs.conntrack=1
  sysctl -w net.ipv4.vs.conntrack=1
  sysctl -w net.ipv4.vs.debug_level=12
}

init_ipvs() {
  ipvsadm -A -t 192.168.122.10:3333 -s rr
#   ipvsadm -a -t 192.168.122.10:3333 -r $out:3341 -m
  ipvsadm -a -t 192.168.122.10:3333 -r $vm2:3342 -m
#   ipvsadm -d -t 192.168.122.10:3333 -r 192.168.122.232:3342 
#   iptables -t nat -A OUTPUT -p tcp -d 192.168.122.10 -dport 3333  -j REDIRECT --to-port 3342

}

clean
update_ipvs_mod
init_sysctl
init_iptable
init_ipvs

./http-echo 3342 &
#echo -n 'module ip_vs +p' > /sys/kernel/debug/dynamic_debug/control
#echo "12" > /proc/sys/net/ipv4/vs/debug_level

# ip address add 192.168.122.10 dev eth0
# ipvsadm -a -t 192.168.122.10:3333 -r 192.168.122.76:12345 -m

# dmesg -c >/dev/null
# clear
# ./curl-amd64 --local-port 12345 192.168.122.10:3333
# echo "xxxxxxxxxxxxxxxx\n"
# dmesg >./d.log
# cat ./d.log
#  iptables-save |grep -v 232|iptables-restore
