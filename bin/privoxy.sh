#!/usr/bin/env bash

docker run                                 \
       -d                                  \
       --cap-add=NET_ADMIN                 \
       --device /dev/net/tun               \
       --name vpn                          \
       -v "$(pwd)/ovpn:/ovpn"              \
       -v "$(pwd)/creds:/credentials:ro"   \
       -p 8118:8118                        \
       -p 9500:9500                        \
       -e MAX_LOAD=50                      \
       -e LOCATION=nl                      \
       -e PROTOCOL=tcp                     \
       ivonet/nordvpn-privoxy:latest

#      -e RECREATE_VPN_CRON="* * * * *"   \
