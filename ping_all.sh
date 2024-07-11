#!/bin/bash

subnet=$1

for i in {1..255}; do
  ip="$subnet.$i"
  ping -c 1 -W 1 $ip > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    mac=$(arp -n $ip | awk '/ether/ {print $3}')
    echo "$ip -> $mac"
  else
    echo "$ip is not reachable"
  fi
done