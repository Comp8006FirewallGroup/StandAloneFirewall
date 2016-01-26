# run on the firewall gateway

### configuration ###

# network interface to LAN behind firewall
NETWORK_INTERFACE="eth1"

# address of this (gateway) machine on LAN behind firewall
GATEWAY_ADDRESS="192.168.0.0"

# subnet address of LAN behind firewall (CIDR notation)
SUBNET_ADDRESS="192.168.0.0/24"

### code - do not touch! ###

# configure network properties
ip addr add $GATEWAY_ADDRESS dev $NETWORK_INTERFACE
ip route add $SUBNET_ADDRESS dev $NETWORK_INTERFACE

# reset iptables
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -t nat -X
iptables -t mangle -X

# enable forwarding and masquerading
# linuxpoison.blogspot.ca/2009/02/how-to-configure-linux-as-internet.html
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
