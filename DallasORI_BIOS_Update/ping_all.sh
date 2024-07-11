#!/bin/bash

subnet=$1
start=${2:-1}
finish=${3:-255}

for i in $(seq $start $finish); do
  ip="$subnet.$i"
  ping -c 1 -W 1 $ip > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    mac=$(arp -n $ip | awk '/ether/ {print $3}')
    echo "$ip -> $mac"
  else
    echo "$ip is not reachable"
  fi
done