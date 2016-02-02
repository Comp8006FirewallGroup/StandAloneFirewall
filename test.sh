#!/bin/sh


## USER CONFIG
ALLOW_TCP_PORTS_OUT="80 22"
ALLOW_UDP_PORTS_OUT="53"
ALLOW_ICMP_TYPES_OUT=""

ALLOW_TCP_PORTS_IN="80 22"
ALLOW_UDP_PORTS_IN="53"
ALLOW_ICMP_TYPES_IN=""

BLOCKED_TCP_PORTS=""
BLOCKED_UDP_PORTS=""

HOST_ADDR="8.8.8.8"
INTERNAL_ADDR="10.210.0.5"      #SPOOFED ADDRESS - has to be checked manualy
MODE="EXTERNAL"

## TEXT COLOR DEFINES ##
txtblk='\e[0;30m' # Black
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
txtdft='\e[0;39m' # default


# IMPLEMENTATION

if [ $MODE = "EXTERNAL" ]
then
  echo "=========================================================="
  echo "==================== ALLOWED PORTS ======================="
  echo "=========================================================="
  for p in $ALLOW_TCP_PORTS_OUT
  do
    echo -e "${txtylw}=========TCP test port: $p =========${txtdft}"
    if hping3 -S -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
    if hping3 -SF -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN/FIN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN/FIN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    fi
  done

  for p in $ALLOW_UDP_PORTS_OUT
  do
    echo -e "${txtylw}=========UDP test port: $p =========${txtdft}"
    if hping3 --udp -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========UDP test port: $p: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========UDP test port: $p: ${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
  done
  for t in $ALLOW_ICMP_TYPES_OUT
  do
    echo -e "${txtylw}=========ICMP Type: $t =================${txtdft}"
    if hping3 --icmp -C $t -c 1 $HOST_ADDR
    then
      echo -e "${txtcyn}=========ICMP test type: $t ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test type: $t ${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
fi
