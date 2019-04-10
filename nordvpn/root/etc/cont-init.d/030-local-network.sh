#!/usr/bin/with-contenv bash

if [ ! -z $NETWORK ]; then
    echo "Bypass requests for local network thru regular connection..."
    gw=`ip route | awk '/default/ {print $3}'`
    ip route add to $NETWORK via $gw dev eth0
    iptables -A OUTPUT --destination $NETWORK -j ACCEPT
fi

if [ ! -z $NETWORK6 ]; then
    echo "Bypass requests for local ip6 network thru regular connection..."
    gw=`ip -6 route | awk '/default/ {print $3}'`
    ip -6 route add to $NETWORK6 via $gw dev eth0
    ip6tables -A OUTPUT --destination $NETWORK6 -j ACCEPT 2> /dev/null
fi

exit 0
