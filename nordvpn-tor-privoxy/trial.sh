#!/usr/bin/env bash

docker run \
       -it \
       --rm \
       --cap-add=NET_ADMIN \
       --device /dev/net/tun \
       --name proxy\
       -v "/Users/ivonet/dev/ivonet-docker-images/_config/nordvpn/ovpn:/ovpn" \
       -v "/Users/ivonet/dev/ivonet-docker-images/_config/nordvpn/creds:/credentials" \
       -p 8118:8118 \
       -e LOCATION=nl \
       -e MAX_LOAD=10 \
       -e RECREATE_VPN_CRON="*/3 * * * *" \
       -e PROTOCOL=tcp \
       ivonet/nordvpn-tor-privoxy:latest
#        /bin/sh
#       --restart unless-stopped \
