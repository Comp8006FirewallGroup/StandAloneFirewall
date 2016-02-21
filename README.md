# StandAloneFirewall
This is a simple standalone firewall intended to be run on an external Linux box intended to be run using iptables and netfilter.

##usage
1. Networking must be configured for the internal machines to route through the firewall box, and the firewall box to be able to route to the internal machines.
2. The top of firewall.sh contains several variables that may be user defined. Most important to be modified are the host address, which is the IP address of the firewall machine, the subnet address which is the subnet the host is routing to, and the DNS used by both machines.
```bash
# general
IPT="iptables"
PS4='$LINENO '

# network interfaces
WAN_NIC="enp0s3"
LAN_NIC="enp0s8"

# addresses
HOST_ADDR="10.64.205.162"
SUBNET_ADDR="192.168.56.0/24"
DHCP_SERVERS="0.0.0.0/0"
DNS_SERVERS="8.8.8.8"

# allowed ICMP packet types
INBOUND_ICMP_TYPES="0"
OUTBOUND_ICMP_TYPES="8"

# TCP servers on LAN accessible from WAN
# syntax: [public port 1],[private address 1],[private port 1] [public port 2],[private address 2],[private port 2]
# example: 80,192.168.1.1,8080 22,192.168.1.5,22
LAN_TCP_SVRS="21,192.168.56.101,21 20,192.168.56.101,20 22,192.168.56.101,22 80,192.168.56.101,80"

# TCP servers on WAN accessible from LAN
WAN_TCP_SVRS="22 80 443"

# UDP servers on LAN accessible from WAN
# syntax: [public port 1],[private address 1],[private port 1] [public port 2],[private address 2],[private port 2]
# example: 80,192.168.1.1,8080 22,192.168.1.5,22
LAN_UDP_SVRS="22,192.168.56.101,22"

# UDP servers on WAN accessible from LAN
WAN_UDP_SVRS=""

# TCP traffic to minimize delay for
TCP_MINIMIZE_DELAY="22 21"

# TCP traffic to maximize throughput for
TCP_MAXIMIZE_THROUGHPUT="20"

# UDP traffic to minimize delay for
UDP_MINIMIZE_DELAY=""

# UDP traffic to maximize throughput for
UDP_MAXIMIZE_THROUGHPUT="22"

# addresses
WAN_ADDR="0.0.0.0/0"
BROADCAST_SRC_ADDR="0.0.0.0"
BROADCAST_DEST_ADDR="255.255.255.255"

# ports
UNPRIV_PORTS="1024:65535"
PRIV_PORTS="0:1023"
```
3. The firewall can be envoked using
```bash
sh firewall.sh
```
from the project directory.

4. If the test script is configured it can be used to test the firewall by running
```bash
sh test.sh
```
from the project directory

5. The firewall can be halted by running
```bash
sh firewall.sh stop
```
