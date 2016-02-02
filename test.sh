#!/bin/sh

ALLOW_TCP_PORTS=""

ALLOW_UDP_PORTS=""

FIREWALL_ADDR=""
REMOTE_ADDR=""

echo "======== ALLOWED PORTS ========"
for $p in $TCP_PORTS
do
  echo "=========TCP test port: $p SYN     ========="
  if [ hping3 -S -p $p $FIREWALL_ADDR ]
  then
      echo "\e[0;31m FAILED"
  else
      echo "\e[0;31m PASSED"
  fi
  echo "=========TCP test port: $p SYN/FIN ========="
  if [ hping3 -S -p $p $FIREWALL_ADDR ]

  fi
done


echo "======= DENYED PORTS ======="
