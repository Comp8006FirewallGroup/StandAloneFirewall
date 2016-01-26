# run on machines on the LAN behind the firewall gateway

### configuratoin ###

# network interface to LAN
NETWORK_INTERFACE="eth0"

# address of this machine on the LAN
HOST_ADDRESS="192.168.0.1"

# subnet address of this LAN
SUBNET_ADDRESS="192.168.0.0/24"

# LAN's gateway to Internet
GATEWAY_ADDRESS="192.168.0.0"

### code - do not touch! ###

# configure network properties
ip addr add $HOST_ADDRESS dev $NETWORK_INTERFACE
ip route add $SUBNET_ADDRESS dev $NETWORK_INTERFACE
ip route add default via $GATEWAY_ADDRESS dev $NETWORK_INTERFACE

