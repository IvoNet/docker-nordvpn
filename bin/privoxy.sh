#!/usr/bin/env bash

docker run                                \
       -d                                 \
       --cap-add=NET_ADMIN                \
       --device /dev/net/tun              \
       --name proxy                       \
       --restart unless-stopped           \
       -v "$(pwd)/ovpn:/ovpn"             \
       -v "$(pwd)/creds:/credentials:ro"  \
       -p 8118:8118                       \
       -e LOCATION=nl                     \
       -e MAX_LOAD=10                     \
       -e PROTOCOL=udp                    \
       ivonet/nordvpn-privoxy:latest

docker logs -f proxy
