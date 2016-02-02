#!/bin/sh
ALLOW_TCP_PORTS="80 22"

ALLOW_UDP_PORTS=""

TARGET_ADDR="google.com"
HOME_ADDR=""
MODE="INTERNAL"

txtblk='\e[0;30m' # Black
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
txtdft='\e[0;39m' # default



if [ $MODE = "INTERNAL" ]
then
  echo "=========================================================="
  echo "==================== ALLOWED PORTS ======================="
  echo "=========================================================="
  for p in $ALLOW_TCP_PORTS
  do
    echo -e "${txtylw}=========TCP test port: $p =========${txtdft}"
    if hping3 -S -c 1 -p $p $TARGET_ADDR > /dev/null
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    fi
    if hping3 -SF -c 1 -p $p $TARGET_ADDR > /dev/null
    then
      echo -e "${txtcyn}=========TCP test port: $p SYN/FIN:${txtred} FAILED ${txtcyn}=========${txtdft}"
    else
      echo -e "${txtcyn}=========TCP test port: $p SYN/FIN:${txtgrn} PASSED ${txtcyn}=========${txtdft}"
    fi
  done
fi
