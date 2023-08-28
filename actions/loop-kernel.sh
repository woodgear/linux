#!/bin/bash
scp -r $PWD/actions/loop_in_vm.sh root@192.168.122.76:/root/loop.sh
make -j 10
sudo rm -rf /lib/modules/5.13.0wg+/
sudo mkdir /lib/modules/5.13.0wg+/
sudo make modules_install
sudo rm -rf /lib/modules/5.13.0wg+/build
sudo rm -rf /lib/modules/5.13.0wg+/source
scp -r /lib/modules/5.13.0wg+ root@192.168.122.76:/lib/modules/
tmux send-keys -t 0 C-c ' ./loop.sh' C-m
