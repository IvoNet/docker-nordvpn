FROM ivonet/python-alpine-s6:3.14.0a3-alpine3.21-v3.2.0.1

LABEL maintainer="IvoNet.nl"

RUN apk --no-cache --no-progress add jq iptables ip6tables openvpn                   \
 && pip install requests                                                             \
 && mkdir -p /vpn                                                                    \
 && mkdir -p /ovpn                                                                   \
 && mkdir -p /credentials                                                            \
 && rm -rf /tmp/*

ENV HOME=/root                                                                       \
    API_SERVER_STATS="https://api.nordvpn.com/v1/servers?limit=0"                    \
    API_OVPN_FILES="https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip" \
    MAX_LOAD=30

HEALTHCHECK --start-period=60s --timeout=15s --interval=60s                          \
        CMD if [[ $( curl -s https://nordvpn.com/wp-admin/admin-ajax.php?action=get_user_info_data | jq -r '.["status"]' ) = true ]] ; then exit 0; else exit 1; fi

COPY root/ /

VOLUME ["/ovpn", "/credentials"]

ENTRYPOINT ["/init"]

#CMD ["/usr/sbin/openvpn", "--cd", "/vpn", "--config", "/vpn/auth", "--auth-user-pass", "/vpn/config.ovpn", "--auth-nocache"]
