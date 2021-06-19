FROM ivonet/alpine-python-s6:3.13-3.9.5-2.2.0.3

LABEL maintainer="IvoNet.nl"

RUN apk --no-cache --no-progress add jq iptables ip6tables openvpn                   \
 && pip install requests                                                             \
 && mkdir -p /vpn                                                                    \
 && mkdir -p /ovpn                                                                   \
 && mkdir -p /credentials                                                            \
 && rm -rf /tmp/*

ENV HOME=/root                                                                       \
    API_SERVER="https://api.nordvpn.com/server"                                      \
    API_SERVER_STATS="https://nordvpn.com/api/server/stats"                          \
    API_OVPN_FILES="https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip" \
    MAX_LOAD=30

HEALTHCHECK --start-period=60s --timeout=15s --interval=60s                          \
        CMD if [[ $( curl -s https://api.nordvpn.com/vpn/check/full | jq -r '.["status"]' ) = "Protected" ]] ; then exit 0; else exit 1; fi

COPY root/ /

VOLUME ["/ovpn", "/credentials"]

ENTRYPOINT ["/init"]
