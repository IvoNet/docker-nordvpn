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
       -e MAX_LOAD=10 \
       -e LOCATION=nl \
       -e PROTOCOL=tcp \
       ivonet/nordvpn-tor-privoxy:latest
