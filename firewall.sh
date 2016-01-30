#!/bin/sh

#general
IPT="iptables"
ENABLE_DHCP="1"

PS4='$LINENO '

#IPS
INTERNET="wlp2s0"
IPADDR="10.64.205.150"
LOOPBACK="127.0.0.1"
NAMESERVER="0.0.0.0/0"

#chains
USER_CHAINS="ssh www"

#ports
UNPRIVPORTS="1024:65535"
SSH_PORTS="22"
DHCP_PORT="67:68"
DNS_PORT="53"


$IPT -F
$IPT -X
$IPT --policy INPUT ACCEPT
$IPT --policy OUTPUT ACCEPT
$IPT --policy FORWARD ACCEPT

if [ "$1" = "stop" ]
then
	echo "Firewall cleared"
	exit 0
fi


$IPT --policy INPUT DROP
$IPT --policy OUTPUT DROP
$IPT --policy FORWARD DROP

#Create user tables
for UC in $USER_CHAINS
do
	$IPT -N $UC
done

if [ $ENABLE_DHCP = "1" ]
then
	$IPT -A OUTPUT -o $INTERNET -p udp \
				--dport 67:68 \
				--sport $UNPRIVPORTS \
				-j ACCEPT
	$IPT -A INPUT -i $INTERNET -p udp \
				--sport 67:68 \
				--dport $UNPRIVPORTS \
				-j ACCEPT
fi


#catch all set nameservers
for NS in $NAMESERVER
do
$IPT -A OUTPUT -o $INTERNET -p udp \
			--dport $DNS_PORT \
			--sport $UNPRIVPORTS \
			-j ACCEPT

$IPT -A INPUT -i $INTERNET -p udp \
			--sport $DNS_PORT \
			--dport $UNPRIVPORTS \
			-j ACCEPT
done

## SSH
$IPT -A OUTPUT -p tcp --dport 22 -j ssh
$IPT -A INPUT  -p tcp --sport 22 -j ssh


$IPT -A ssh -o $INTERNET -p tcp \
			--sport $UNPRIVPORTS \
			-d $IPADDR --dport 22 -j ACCEPT

$IPT -A ssh -i $INTERNET -p tcp \
		 -s $IPADDR --sport 22 \
		 --dport $UNPRIVPORTS -j ACCEPT

## WWW
$IPT -A OUTPUT -m tcp -p tcp --sport 80 -j www
$IPT -A INPUT  -m tcp -p tcp --sport 80 -j www
$IPT -A OUTPUT -m tcp -p tcp --dport 443 -j www
$IPT -A INPUT  -m tcp -p tcp --sport 443 -j www

$IPT -A www -o $INTERNET -m tcp -p tcp \
			-s $IPADDR --sport $UNPRIVPORTS \
			--dport 80 -j ACCEPT

$IPT -A www -i $INTERNET -m tcp -p tcp \
			--sport 80 \
			-d $IPADDR --dport $UNPRIVPORTS -j ACCEPT

$IPT -A www -i 	$INTERNET -m tcp -p tcp \
			--sport $UNPRIVPORTS \
			-d $IPADDR --dport 80 -j DROP

$IPT -A www -o $INTERNET -m tcp -p tcp \
			-s $IPADDR --sport $UNPRIVPORTS \
			--dport 443 -j ACCEPT

$IPT -A www -i $INTERNET -m tcp -p tcp \
			--sport 443 \
			-d $IPADDR --dport $UNPRIVPORTS -j ACCEPT

$IPT -A www -i 	$INTERNET -m tcp -p tcp \
			--sport $UNPRIVPORTS \
			-d $IPADDR --dport 443 -j DROP


$IPT -A www
