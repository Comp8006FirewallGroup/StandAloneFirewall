# run on the firewall gateway
# before running script, make sure that:
# * appropriate NICs are enabled / disabled (LAN_NETWORK_INTERFACE and WAN_NETWORK_INTERFACE are enabled, the rest are disabled)

### configuration ###

# network interface to LAN behind firewall
LAN_NETWORK_INTERFACE="eth0"

# network interface to WAN beyond firewall
WAN_NETWORK_INTERFACE="wlan0"

# address of this (gateway) machine on LAN behind firewall
GATEWAY_ADDRESS="10.0.0.0"

# subnet address of LAN behind firewall (CIDR notation)
SUBNET_ADDRESS="10.0.0.0/24"

### code - do not touch! ###

# enable forwarding (requires root)
echo "1" > /proc/sys/net/ipv4/ip_forward

# configure network properties
ip addr replace $GATEWAY_ADDRESS dev $LAN_NETWORK_INTERFACE valid_lft forever preferred_lft forever
ip route replace $SUBNET_ADDRESS dev $LAN_NETWORK_INTERFACE proto static

# reset iptables
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -t nat -X
iptables -t mangle -X

# enable forwarding and masquerading
# linuxpoison.blogspot.ca/2009/02/how-to-configure-linux-as-internet.html
iptables -t nat -A POSTROUTING -o $WAN_NETWORK_INTERFACE -j MASQUERADE
