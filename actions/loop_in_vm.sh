#!/bin/bash
echo "in vm"
ip address del 192.168.121.100/32 dev eth0 || true
ipvsadm -d -t 192.168.122.10:3333 -r 192.168.122.76:22 || true
ipvsadm -D -t 192.168.122.10:3333 || true
rmmod ip_vs_rr
rmmod ip_vs

modprobe ip_vs

ip address add 192.168.122.10 dev eth0
# ipvsadm -a -t 192.168.122.10:3333 -r 192.168.122.76:12345 -m
ipvsadm -A -t 192.168.122.10:3333 -s rr
ipvsadm -a -t 192.168.122.10:3333 -r 10.0.0.222:8000 -m

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.arp_accept=1
sysctl -w net.ipv4.vs.conntrack=1
