#!/bin/bash
echo "in vm"

rip_ip=192.168.31.210
iptables -t nat -C POSTROUTING -j MASQUERADE -d "$rip_ip/32" -m comment --comment "cong"
iptables -t nat -A POSTROUTING -j MASQUERADE -d "$rip_ip/32" -m comment --comment "cong"

rip=$rip_ip:8000
ip address del 192.168.121.100/32 dev eth0 || true
ipvsadm -d -t 192.168.122.10:3333 -r 192.168.122.76:22 || true
ipvsadm -D -t 192.168.122.10:3333 || true
rmmod ip_vs_rr
rmmod ip_vs

modprobe ip_vs


sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.arp_accept=1
sysctl -w net.ipv4.vs.conntrack=1
sysctl -w net.ipv4.vs.conntrack=1
sysctl -w net.ipv4.vs.debug_level=12


#echo -n 'module ip_vs +p' > /sys/kernel/debug/dynamic_debug/control
#echo "12" > /proc/sys/net/ipv4/vs/debug_level

ip address add 192.168.122.10 dev eth0
# ipvsadm -a -t 192.168.122.10:3333 -r 192.168.122.76:12345 -m
ipvsadm -A -t 192.168.122.10:3333 -s rr
ipvsadm -a -t 192.168.122.10:3333 -r $rip -m


dmesg -c > /dev/null
clear
./curl-amd64 --local-port 12345 192.168.122.10:3333
echo "xxxxxxxxxxxxxxxx\n"
dmesg > ./d.log
cat ./d.log
