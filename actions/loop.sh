#!/bin/bash
source ./actions/actions.sh
lx-build
vm1=192.168.122.231
vm2=192.168.122.232
# scp -r $PWD/actions/loop_in_vm1-case2.sh root@$vm1:/root/loop.sh
# lx-sync $vm1
scp -r $PWD/actions/loop_in_vm1-case2.sh root@$vm2:/root/loop.sh
lx-sync $vm2
# tmux send-keys -t 0 C-c ' ./loop.sh' C-m
