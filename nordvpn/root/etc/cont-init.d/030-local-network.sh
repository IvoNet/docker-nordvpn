#!/command/with-contenv bash
###############################################################################
# Will adjust the iptables to allow for local network
###############################################################################

if [ ! -z ${NETWORK} ]; then
  echo "Bypass requests for local network thru regular connection..."
  gw=$(ip route | awk '/default/ {print $3}')
  ip route add to ${NETWORK} via ${gw} dev eth0
  iptables -A OUTPUT --destination ${NETWORK} -j ACCEPT
fi

if [ ! -z ${NETWORKS} ]; then
  echo "Bypass requests for multiple networks thru regular connection...."
  gw=$(ip route | awk '/default/ {print $3}')

  IFS=','
  read -rasplitIFS <<<"$NETWORKS"

  for net in "${splitIFS[@]}"; do
    echo ${net}
    ip route add to ${net} via ${gw} dev eth0
    iptables -A OUTPUT --destination ${net} -j ACCEPT
  done
fi

if [ ! -z ${NETWORK6} ]; then
  echo "Bypass requests for local ip6 network thru regular connection..."
  gw=$(ip -6 route | awk '/default/ {print $3}')
  ip -6 route add to ${NETWORK6} via ${gw} dev eth0
  ip6tables -A OUTPUT --destination ${NETWORK6} -j ACCEPT 2>/dev/null
fi

if [ ! -z ${NETWORKS6} ]; then
  echo "Bypass requests for multiple networks thru regular connection..."
  gw=$(ip route | awk '/default/ {print $3}')

  IFS=','
  read -rasplitIFS <<<"$NETWORKS6"

  for net in "${splitIFS[@]}"; do
    ip -6 route add to ${net} via ${gw} dev eth0
    ip6tables -A OUTPUT --destination ${net} -j ACCEPT 2>/dev/null
  done
fi

exit 0
