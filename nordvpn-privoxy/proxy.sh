#!/usr/bin/env bash

docker run \
       -d \
       --cap-add=NET_ADMIN \
       --device /dev/net/tun \
       --name proxy \
       --restart unless-stopped \
       -v "/Users/ivonet/dev/ivonet-docker-images/_config/nordvpn/ovpn:/ovpn" \
       -v "/Users/ivonet/dev/ivonet-docker-images/_config/nordvpn/creds:/credentials" \
       -p 8118:8118 \
       -e LOCATION=nl \
       -e MAX_LOAD=10 \
       -e PROTOCOL=udp \
       ivonet/nordvpn-privoxy:latest


docker logs -f proxy
