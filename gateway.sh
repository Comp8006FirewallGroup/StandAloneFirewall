# run on the firewall gateway
# before running script, make sure that:
# * appropriate NICs are enabled / disabled (LAN_NETWORK_INTERFACE and WAN_NETWORK_INTERFACE are enabled, the rest are disabled)

### configuration ###

# network interface to LAN behind firewall
LAN_NETWORK_INTERFACE="eth0"

# network interface to WAN beyond firewall
WAN_NETWORK_INTERFACE="wlan0"

# address of this (gateway) machine on LAN behind firewall
GATEWAY_ADDRESS="10.210.0.0"

# subnet address of LAN behind firewall (CIDR notation)
SUBNET_ADDRESS="10.210.0.0/24"

# DNS server addresses
NAME_SERVERS="8.8.8.8"

### code - do not touch! ###

# enable forwarding (requires root)
echo "1" > /proc/sys/net/ipv4/ip_forward

# configure DNS servers
echo "nameserver $NAME_SERVERS" > /etc/resolv.conf

# configure network properties
ip addr replace $GATEWAY_ADDRESS dev $LAN_NETWORK_INTERFACE valid_lft forever preferred_lft forever
ip route replace $SUBNET_ADDRESS dev $LAN_NETWORK_INTERFACE proto static
