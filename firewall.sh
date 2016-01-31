# !/bin/sh

### configuration ###

# general
IPT="iptables"
PS4='$LINENO '

# network interfaces
WAN_NIC="wlan0"
LAN_NIC="eth0"

# addresses
HOST_ADDR="192.168.1.74"
SUBNET_ADDR="10.210.0.0/24"
DHCP_SERVERS="192.168.1.254"
DNS_SERVERS="8.8.8.8"

# allowed ICMP packet types
INBOUND_ICMP_TYPES="0"
OUTBOUND_ICMP_TYPES="8"

# allowed TCP ports
LOCAL_TCP_SVRS="22 80"
REMOTE_TCP_SVRS="22 80 443"

# allowed UDP ports
LOCAL_UDP_SVRS="22 80"
REMOTE_UDP_SVRS="53"

### implementation - do not touch! ###

# addresses
ANY_ADDR="0.0.0.0/0"
BROADCAST_SRC_ADDR="0.0.0.0"
BROADCAST_DEST_ADDR="255.255.255.255"

# ports
UNPRIV_PORTS="1024:65535"
PRIV_PORTS="0:1023"

# reset firewall
$IPT -F
$IPT -t nat -F
$IPT -t mangle -F
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT

if [ "$1" = "stop" ]
then
	echo "Firewall cleared"
	exit 0
fi

# set default chain policies
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# enable forwarding and masquerading
# linuxpoison.blogspot.ca/2009/02/how-to-configure-linux-as-internet.html
$IPT -t nat -A POSTROUTING -o $WAN_NIC -j MASQUERADE

# create user chains
USER_CHAINS="DHCP DNS ICMP TCP_SVR TCP_CLNT UDP_CLNT"
for CHAIN in $USER_CHAINS
do
	$IPT -N $CHAIN
	$IPT -A $CHAIN -j ACCEPT
done

# enable DHCP traffic to DHCP servers
for SVR in $DHCP_SERVERS
do
	$IPT -A OUTPUT -o $WAN_NIC -p udp \
				-s $BROADCAST_SRC_ADDR --sport 67:68 \
				-d $BROADCAST_DEST_ADDR --dport 67:68 \
				-j DHCP
	$IPT -A INPUT -i $WAN_NIC -p udp \
				-s $SVR --sport 67 \
				-d $SUBNET_ADDR --dport 68 \
				-j DHCP
	$IPT -A OUTPUT -o $WAN_NIC -p udp \
				-d $SVR --dport 67 \
				-s $HOST_ADDR --sport 68 \
				-j DHCP
	$IPT -A INPUT -i $WAN_NIC -p udp \
				-s $SVR --sport 67 \
				-d $HOST_ADDR --dport 68 \
				-j DHCP
done

# enable DNS traffic to DNS servers
for SVR_ADDR in $DNS_SERVERS
do
	$IPT -A FORWARD -p udp \
				-i $LAN_NIC -s $SUBNET_ADDR --sport $UNPRIV_PORTS \
				-o $WAN_NIC -d $SVR_ADDR --dport 53 \
				-j DNS
	$IPT -A FORWARD -p udp \
				-i $WAN_NIC -s $SVR_ADDR --sport 53 \
				-o $LAN_NIC -d $SUBNET_ADDR --dport $UNPRIV_PORTS \
				-j DNS
done

# enable inbound ICMP traffic based on type
for ICMP_TYPE in $INBOUND_ICMP_TYPES
do
	$IPT -A FORWARD -p icmp --icmp-type $ICMP_TYPE \
				-i $WAN_NIC -s $ANY_ADDR \
				-o $LAN_NIC -d $SUBNET_ADDR \
				-j ICMP
done

# enable outbound ICMP traffic based on type
for ICMP_TYPE in $OUTBOUND_ICMP_TYPES
do
	$IPT -A FORWARD -p icmp --icmp-type $ICMP_TYPE \
				-i $LAN_NIC -s $SUBNET_ADDR \
				-o $WAN_NIC -d $ANY_ADDR \
				-j ICMP
done

# enable inbound TCP traffic to local TCP servers - TODO do some kind of port forwarding...
for SVR_PORT in $LOCAL_TCP_SVRS
do
	$IPT -A INPUT -i $WAN_NIC -p tcp \
				-d $HOST_ADDR --dport $SVR_PORT \
				-s $ANY_ADDR --sport $UNPRIV_PORTS \
				-m state --state NEW,ESTABLISHED -j TCP_SVR
	$IPT -A OUTPUT -o $WAN_NIC -p tcp \
				-s $HOST_ADDR --sport $SVR_PORT \
				-d $ANY_ADDR --dport $UNPRIV_PORTS \
				-m state --state ESTABLISHED -j TCP_SVR
done

# enable outbound TCP traffic to remote TCP servers
for SVR_PORT in $REMOTE_TCP_SVRS
do
	$IPT -A FORWARD -p tcp \
				-i $WAN_NIC -s $ANY_ADDR --sport $SVR_PORT \
				-o $LAN_NIC -d $SUBNET_ADDR --dport $UNPRIV_PORTS \
				-m state --state ESTABLISHED -j TCP_CLNT
	$IPT -A FORWARD -p tcp \
				-i $LAN_NIC -s $SUBNET_ADDR --sport $UNPRIV_PORTS \
				-o $WAN_NIC -d $ANY_ADDR --dport $SVR_PORT \
				-m state --state NEW,ESTABLISHED -j TCP_CLNT
done

# enable inbound UDP traffic to local UDP servers - TODO do some kind of port forwarding...
for SVR_PORT in $LOCAL_UDP_SVRS
do
	$IPT -A INPUT -i $WAN_NIC -p udp \
				-d $HOST_ADDR --dport $SVR_PORT \
				-s $ANY_ADDR --sport $UNPRIV_PORTS \
				-j UDP_SVR
	$IPT -A OUTPUT -o $WAN_NIC -p udp \
				-s $HOST_ADDR --sport $SVR_PORT \
				-d $ANY_ADDR --dport $UNPRIV_PORTS \
				-j UDP_SVR
done

# enable outbound UDP traffic to remote UDP servers
for SVR_PORT in $REMOTE_UDP_SVRS
do
	$IPT -A FORWARD -p udp \
				-i $WAN_NIC -s $ANY_ADDR --sport $SVR_PORT \
				-o $LAN_NIC -d $SUBNET_ADDR --dport $UNPRIV_PORTS \
				-j UDP_CLNT
	$IPT -A FORWARD -p udp \
				-i $LAN_NIC -s $SUBNET_ADDR --sport $UNPRIV_PORTS \
				-o $WAN_NIC -d $ANY_ADDR --dport $SVR_PORT \
				-j UDP_CLNT
done

# questions:
# drop all packets destined for the firewall from the outside??? including established TCP connections? how about UDP packets?
