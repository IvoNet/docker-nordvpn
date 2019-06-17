#!/usr/bin/env bash

docker run                                \
       -it                                \
       --rm                               \
       --cap-add=NET_ADMIN                \
       --device /dev/net/tun              \
       --name privoxy                     \
       -v "$(pwd)/ovpn:/ovpn"             \
       -v "$(pwd)/creds:/credentials:ro"  \
       -p 8118:8118                       \
       -e LOCATION=us                     \
       -e MAX_LOAD=15                     \
       -e PROTOCOL=tcp                    \
       ivonet/nordvpn-privoxy:latest

