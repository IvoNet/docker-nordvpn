#!/usr/bin/with-contenv bash

# resetting iptables
###############################################################################
# Configure the iptables to allow only traffic over the vpn connection
# Exceptions to this rule:
# - the VPN Provider endpoints needed to get this image to work
###############################################################################

iptables --flush
iptables --delete-chain
iptables -t nat --flush
iptables -t nat --delete-chain

# based on knowledge gained on the following site:
# https://www.linode.com/docs/networking/vpn/vpn-firewall-killswitch-for-linux-and-macos-clients/
echo "Setting up the Firewall"
iptables  -F OUTPUT
ip6tables -F OUTPUT 2> /dev/null
iptables  -P OUTPUT DROP
ip6tables -P OUTPUT DROP 2> /dev/null
iptables  -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -o lo -j ACCEPT 2> /dev/null
ip6tables -A OUTPUT -o lo -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -o tun0 -j ACCEPT
ip6tables -A OUTPUT -o tun0 -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -d $(ip -o addr show dev eth0 | awk '$3 == "inet" {print $4}') -j ACCEPT
ip6tables -A OUTPUT -d $(ip -o addr show dev eth0 | awk '$3 == "inet6" {print $4; exit}') -j ACCEPT 2> /dev/null
# DNS requests
iptables  -A OUTPUT -p udp --dport 53 -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 53 -j ACCEPT 2> /dev/null

if [ -z "$PROTOCOL" ]; then
    export PROTOCOL="tcp/udp"
fi
# https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
if [[ "$PROTOCOL" == *"udp"* ]]; then
   echo "Allowing connections over the ovpn udp port 1194..."
   iptables  -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT
   ip6tables -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT 2> /dev/null
fi

if [[ "$PROTOCOL" == *"tcp"* ]]; then
   echo "Allowing connections over the ovpn tcp port 443 ..."
   iptables  -A OUTPUT -o eth0 -p tcp --dport 443 -j ACCEPT
   ip6tables -A OUTPUT -o eth0 -p tcp --dport 443 -j ACCEPT 2> /dev/null
fi


echo "Bypass requests to NordVPN thru regular connection"
iptables  -A OUTPUT -o eth0 -d `echo $API_SERVER | awk -F/ '{print $3}'` -j ACCEPT
ip6tables -A OUTPUT -o eth0 -d `echo $API_SERVER | awk -F/ '{print $3}'` -j ACCEPT 2> /dev/null

iptables  -A OUTPUT -o eth0 -d `echo $API_SERVER_STATS | awk -F/ '{print $3}'` -j ACCEPT
ip6tables -A OUTPUT -o eth0 -d `echo $API_SERVER_STATS | awk -F/ '{print $3}'` -j ACCEPT 2> /dev/null

iptables  -A OUTPUT -o eth0 -d `echo $API_OVPN_FILES | awk -F/ '{print $3}'` -j ACCEPT
ip6tables -A OUTPUT -o eth0 -d `echo $API_OVPN_FILES | awk -F/ '{print $3}'` -j ACCEPT 2> /dev/null

exit 0
