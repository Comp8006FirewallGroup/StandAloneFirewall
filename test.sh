#!/bin/sh


## USER CONFIG
ALLOW_TCP_PORTS_OUT="80 22"
ALLOW_UDP_PORTS_OUT=""
ALLOW_ICMP_TYPES_OUT="8"

ALLOW_TCP_PORTS_IN="80 22"
ALLOW_UDP_PORTS_IN="22"
ALLOW_ICMP_TYPES_IN="0"

BLOCK_TCP_PORTS_OUT="80 22"
BLOCK_UDP_PORTS_OUT="53"
BLOCK_ICMP_TYPES_OUT="8"

BLOCK_TCP_PORTS_IN="80 22"
BLOCK_UDP_PORTS_IN="53"
BLOCK_ICMP_TYPES_IN="0"

HOST_ADDR="8.8.8.8"
INTERNAL_ADDR="10.210.0.5"      #SPOOFED ADDRESS - has to be checked manualy

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

if [ "$1" = "external" ]
then
  echo "=========================================================="
  echo "==================== ALLOWED PORTS ======================="
  echo "=========================================================="
  for p in $ALLOW_TCP_PORTS_IN
  do
    echo -e "${txtylw}=========TCP test port: $p =========${txtdft}"
    if hping3 -S -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    fi
  done

  for p in $ALLOW_UDP_PORTS_IN
  do
    echo -e "${txtylw}=========UDP test port: $p =========${txtdft}"
    if hping3 --udp -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========UDP test port: $p: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========UDP test port: $p: ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    fi
  done
  for t in $ALLOW_ICMP_TYPES_IN
  do
    echo -e "${txtylw}=========ICMP Type: $t =================${txtdft}"
    if hping3 --icmp -C $t -c 1 $HOST_ADDR
    then
      echo -e "${txtcyn}=========ICMP test type: $t ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========ICMP test type: $t ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    fi
  done

  echo "=========================================================="
  echo "==================== BLOCKED PORTS ======================="
  echo "=========================================================="
  for p in $BLOCK_TCP_PORTS_IN
  do
    echo -e "${txtylw}=========TCP test port: $p =========${txtdft}"
    if hping3 -S -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
  done

  for p in $BLOCK_UDP_PORTS_IN
  do
    echo -e "${txtylw}=========UDP test port: $p =========${txtdft}"
    if hping3 --udp -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========UDP test port: $p: ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========UDP test port: $p: ${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
  done
  for t in $BLOCK_ICMP_TYPES_IN
  do
    echo -e "${txtylw}=========ICMP Type: $t =================${txtdft}"
    if hping3 --icmp -C $t -c 1 $HOST_ADDR
    then
      echo -e "${txtcyn}=========ICMP test type: $t ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========ICMP test type: $t ${txtgrn} FAILED ${txtcyn}=========${txtdft}"
    fi
  done

  echo -e "${txtylw}========= BLOCK OUTSIDE HOSTS USING INTERNAL ADDRs =========${txtdft}"
  arr=($ALLOW_TCP_PORTS_OUT)
  if hping3 --spoof -p $INTERNAL_ADDR ${arr[0]} -S -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST DIDN'T RESPOND: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST RESPONDED:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi

  echo -e "${txtylw}========= BLOCK WRONG WAY CONNECTIONS =========${txtdft}"
  if hping3 -S -s ${arr[0]} -p 2222 -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST DIDN'T RESPOND: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST RESPONDED:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi

  echo -e "${txtylw}========= ACCEPT FRAGMENTS =========${txtdft}"
  if hping3 -S -p ${arr[0]} --frag -d 1000 -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST RESPONDED: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST DIDNT RESPOND:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi

  echo -e "${txtylw}========= DROP CONNECTIONS With SYN/FIN set =========${txtdft}"
  if hping3 -SF -s ${arr[0]} -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST DIDN'T RESPOND: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST RESPONDED:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi
else ##################################################################################################################
  echo "=========================================================="
  echo "==================== ALLOWED PORTS ======================="
  echo "=========================================================="
  for p in $ALLOW_TCP_PORTS_IN
  do
    echo -e "${txtylw}=========TCP test port: $p =========${txtdft}"
    if hping3 -S -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    fi
  done

  for p in $ALLOW_UDP_PORTS_IN
  do
    echo -e "${txtylw}=========UDP test port: $p =========${txtdft}"
    if hping3 --udp -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========UDP test port: $p: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========UDP test port: $p: ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    fi
  done
  for t in $ALLOW_ICMP_TYPES_IN
  do
    echo -e "${txtylw}=========ICMP Type: $t =================${txtdft}"
    if hping3 --icmp -C $t -c 1 $HOST_ADDR
    then
      echo -e "${txtcyn}=========ICMP test type: $t ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========ICMP test type: $t ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    fi
  done

  echo "=========================================================="
  echo "==================== BLOCKED PORTS ======================="
  echo "=========================================================="
  for p in $BLOCK_TCP_PORTS_IN
  do
    echo -e "${txtylw}=========TCP test port: $p =========${txtdft}"
    if hping3 -S -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
  done

  for p in $BLOCK_UDP_PORTS_IN
  do
    echo -e "${txtylw}=========UDP test port: $p =========${txtdft}"
    if hping3 --udp -c 1 -p $p $HOST_ADDR
    then
      echo -e "${txtcyn}=========UDP test port: $p: ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========UDP test port: $p: ${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
  done
  for t in $BLOCK_ICMP_TYPES_IN
  do
    echo -e "${txtylw}=========ICMP Type: $t =================${txtdft}"
    if hping3 --icmp -C $t -c 1 $HOST_ADDR
    then
      echo -e "${txtcyn}=========ICMP test type: $t ${txtylw} CHECK ACCOUNTING ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========ICMP test type: $t ${txtgrn} FAILED ${txtcyn}=========${txtdft}"
    fi
  done

  echo -e "${txtylw}========= BLOCK OUTSIDE HOSTS USING INTERNAL ADDRs =========${txtdft}"
  arr=($ALLOW_TCP_PORTS_OUT)
  if hping3 --spoof -p $INTERNAL_ADDR ${arr[0]} -S -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST DIDN'T RESPOND: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST RESPONDED:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi

  echo -e "${txtylw}========= BLOCK WRONG WAY CONNECTIONS =========${txtdft}"
  if hping3 -S -s ${arr[0]} -p 2222 -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST DIDN'T RESPOND: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST RESPONDED:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi

  echo -e "${txtylw}========= ACCEPT FRAGMENTS =========${txtdft}"
  if hping3 -S -p ${arr[0]} --frag -d 1000 -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST RESPONDED: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST DIDNT RESPOND:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi

  echo -e "${txtylw}========= DROP CONNECTIONS With SYN/FIN set =========${txtdft}"
  if hping3 -SF -s ${arr[0]} -c 1 $HOST_ADDR
    then
    echo -e "${txtcyn}========= HOST DIDN'T RESPOND: ${txtgrn} PASSED ${txtcyn}=========${txtdft}"
  else
    echo -e "${txtcyn}========= HOST RESPONDED:${txtred} FAILED ${txtcyn}=========${txtdft}"
  fi
fi
