# !/bin/sh
echo "# !/bin/sh"

### configuration ###
echo "### configuration ###"

# general
echo "# general"
IPT="iptables"
ALLOWED_ICMP_SERVICES="???"

PS4='$LINENO '

# network interfaces
echo "# network interfaces"
WAN_NIC="wlan0"
LAN_NIC="eth0"

# addresses
echo "# addresses"
HOST_ADDR="192.168.1.74"
SUBNET_ADDR="10.210.0.0/24"
DHCP_SERVERS="192.168.1.254"
NAME_SERVERS="8.8.8.8"

# ports
echo "# ports"
UNPRIV_PORTS="1024:65535"
PRIV_PORTS="0:1023"

LOCAL_TCP_SVRS="22 80"
REMOTE_TCP_SVRS="22 80 443"

LOCAL_UDP_SERVERS="22 80"
REMOTE_UDP_SERVERS="22 80 443"

### implementation - do not touch! ###
echo "### implementation - do not touch! ###"

# addresses
echo "# addresses"
LOOPBACK="127.0.0.1"
ANY_ADDR="0.0.0.0/0"
BROADCAST_SRC_ADDR="0.0.0.0"
BROADCAST_DEST_ADDR="255.255.255.255"

# reset firewall
echo "# reset firewall"
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
echo "# set default chain policies"
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# enable forwarding and masquerading
# linuxpoison.blogspot.ca/2009/02/how-to-configure-linux-as-internet.html
$IPT -t nat -A POSTROUTING -o $WAN_NETWORK_INTERFACE -j MASQUERADE

# create user chains
echo "# create user chains"
USER_CHAINS="DHCP DNS ICMP TCP_SVR TCP_CLNT"
for CHAIN in $USER_CHAINS
do
	$IPT -N $CHAIN
	$IPT -A $CHAIN -j ACCEPT
done

# enable DHCP traffic to DHCP servers
echo "# enable DHCP traffic to DHCP servers"
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

for SVR in $NAME_SERVERS
do
	$IPT -A OUTPUT -o $WAN_NIC -p udp \
				-d $SVR --dport 53 \
				-s $HOST_ADDR --sport $UNPRIV_PORTS \
				-j DNS
	$IPT -A INPUT -i $WAN_NIC -p udp \
				-s $SVR --sport 53 \
				-d $HOST_ADDR --dport $UNPRIV_PORTS \
				-j DNS
	$IPT -A FORWARD -p udp \
				-o $WAN_NIC -d $SVR --dport 53 \
				-i $LAN_NIC -s $SUBNET_ADDR --sport $UNPRIV_PORTS \
				-j DNS
	$IPT -A FORWARD -p udp \
				-i $WAN_NIC -s $SVR --sport 53 \
				-o $LAN_NIC -d $SUBNET_ADDR --dport $UNPRIV_PORTS \
				-j DNS
done

# enable inbound TCP traffic to local TCP servers - TODO do some kind of port forwarding...
echo "# enable inbound TCP traffic to local TCP servers"
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
echo "# enable outbound TCP traffic to remote TCP servers"
for SVR_PORT in $REMOTE_TCP_SVRS
do
	$IPT -A INPUT -i $WAN_NIC -p tcp \
				-s $ANY_ADDR --sport $SVR_PORT \
				-d $HOST_ADDR --dport $UNPRIV_PORTS \
				-m state --state ESTABLISHED -j TCP_CLNT
	$IPT -A OUTPUT -o $WAN_NIC -p tcp \
				-d $ANY_ADDR --dport $SVR_PORT \
				-s $HOST_ADDR --sport $UNPRIV_PORTS \
				-m state --state NEW,ESTABLISHED -j TCP_CLNT
	$IPT -A FORWARD -i $WAN_NIC -o $LAN_NIC -p tcp \
				-s $ANY_ADDR --sport $SVR_PORT \
				-d $SUBNET_ADDR --dport $UNPRIV_PORTS \
				-m state --state ESTABLISHED -j TCP_CLNT
	$IPT -A FORWARD -i $LAN_NIC -o $WAN_NIC -p tcp \
				-d $ANY_ADDR --dport $SVR_PORT \
				-s $SUBNET_ADDR --sport $UNPRIV_PORTS \
				-m state --state NEW,ESTABLISHED -j TCP_CLNT
done

# ## SSH
# $IPT -A OUTPUT -p tcp --dport 22 -j ssh
# $IPT -A INPUT  -p tcp --sport 22 -j ssh


# $IPT -A ssh -o $WAN_NIC -p tcp \
# 			--sport $UNPRIV_PORTS \
# 			-d $HOST_ADDR --dport 22 -j ACCEPT

# $IPT -A ssh -i $WAN_NIC -p tcp \
# 		 -s $HOST_ADDR --sport 22 \
# 		 --dport $UNPRIV_PORTS -j ACCEPT

# ## WWW
# $IPT -A OUTPUT -m tcp -p tcp --sport 80 -j www
# $IPT -A INPUT  -m tcp -p tcp --sport 80 -j www
# $IPT -A OUTPUT -m tcp -p tcp --dport 443 -j www
# $IPT -A INPUT  -m tcp -p tcp --sport 443 -j www

# $IPT -A www -o $WAN_NIC -m tcp -p tcp \
# 			-s $HOST_ADDR --sport $UNPRIV_PORTS \
# 			--dport 80 -j ACCEPT

# $IPT -A www -i $WAN_NIC -m tcp -p tcp \
# 			--sport 80 \
# 			-d $HOST_ADDR --dport $UNPRIV_PORTS -j ACCEPT

# $IPT -A www -i 	$WAN_NIC -m tcp -p tcp \
# 			--sport $UNPRIV_PORTS \
# 			-d $HOST_ADDR --dport 80 -j DROP

# $IPT -A www -o $WAN_NIC -m tcp -p tcp \
# 			-s $HOST_ADDR --sport $UNPRIV_PORTS \
# 			--dport 443 -j ACCEPT

# $IPT -A www -i $WAN_NIC -m tcp -p tcp \
# 			--sport 443 \
# 			-d $HOST_ADDR --dport $UNPRIV_PORTS -j ACCEPT

# $IPT -A www -i 	$WAN_NIC -m tcp -p tcp \
# 			--sport $UNPRIV_PORTS \
# 			-d $HOST_ADDR --dport 443 -j DROP


# $IPT -A www
