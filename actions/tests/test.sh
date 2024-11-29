#!/bin/bash

function main() {
  echo "test: start"
  ls /tests
  ipvs-test
  echo "test: over"
}

function ipvs-test() {
  ipvsadm -ln
  mkdir /tests/xx
  cd ./tests/xx
  python3 -m http.server 22345 &
  cd ../
  curl 127.0.0.1:22345 -s -o /dev/null -w '%{time_total} %{http_code}'
  sleep 3
  curl 127.0.0.1:22345 -s -o /dev/null -w '%{time_total} %{http_code}'
  ipvsadm -A -t 199.168.0.1:12345 -s rr
  ipvsadm -a -t 199.168.0.1:12345 -r 127.0.0.1:22345 -m

  local out=$(curl -m 3 199.168.0.1:12345 -s -o /dev/null -w '%{time_total} code:%{http_code}')
  if [[ $out == *"code:200"* ]]; then
    echo "@@@ case: 1 only ipvs should fail | success: false | msg: $out @@@"
  else
    echo "@@@ case: 1 only ipvs should fail | success: true | msg: $out @@@"
  fi

  ip link add alive type dummy
  ip addr add 199.168.0.1 dev alive

  local out=$(curl -m 3 199.168.0.1:12345 -s -o /dev/null -w '%{time_total} code:%{http_code}')
  if [[ $out == *"code:200"* ]]; then
    echo "@@@ case: 2 add nic should ok | success: true | msg: $out @@@"
  else
    echo "@@@ case: 2 add nic should ok | success: false | msg: $out @@@"
  fi
  md5sum /lib/modules/5.13.0wg+/kernel/net/netfilter/ipvs/ip_vs.ko
  echo "ipvsadm: over"
}

if [[ ! -f /tests/not-test ]]; then
  main
else
  echo "test: skip"
fi

if [[ ! -f /tests/not-stop ]]; then
  echo "test: stop"
  reboot -f
fi
