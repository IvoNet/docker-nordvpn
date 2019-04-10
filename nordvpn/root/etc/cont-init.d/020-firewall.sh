#!/usr/bin/with-contenv bash

# resetting iptables

iptables --flush
iptables --delete-chain
iptables -t nat --flush
iptables -t nat --delete-chain

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
iptables  -A OUTPUT -p udp --dport 53 -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 53 -j ACCEPT 2> /dev/null
# Allow the upd openvpn connections
iptables  -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT
ip6tables -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT 2> /dev/null
# allow the tcp openvpn connections
iptables  -A OUTPUT -o eth0 -p tcp --dport 443 -j ACCEPT
ip6tables -A OUTPUT -o eth0 -p tcp --dport 443 -j ACCEPT 2> /dev/null


echo "Bypass requests to NordVPN thru regular connection"
iptables  -A OUTPUT -o eth0 -d `echo $API_SERVER | awk -F/ '{print $3}'` -j ACCEPT
ip6tables -A OUTPUT -o eth0 -d `echo $API_SERVER | awk -F/ '{print $3}'` -j ACCEPT 2> /dev/null

iptables  -A OUTPUT -o eth0 -d `echo $API_OVPN_FILES | awk -F/ '{print $3}'` -j ACCEPT
ip6tables -A OUTPUT -o eth0 -d `echo $API_OVPN_FILES | awk -F/ '{print $3}'` -j ACCEPT 2> /dev/null

iptables  -A OUTPUT -o eth0 -d `echo $API_RECOMMENDED_SERVERS | awk -F/ '{print $3}'` -j ACCEPT
ip6tables -A OUTPUT -o eth0 -d `echo $API_RECOMMENDED_SERVERS | awk -F/ '{print $3}'` -j ACCEPT 2> /dev/null

exit 0
