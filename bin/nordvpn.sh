#!/usr/bin/env bash

docker run                                   \
       -it                                   \
       --rm                                  \
       --cap-add=NET_ADMIN                   \
       --device /dev/net/tun                 \
       --name nordvpn                        \
       -v "$(pwd)/ovpn:/ovpn"                \
       -v "$(pwd)/creds:/credentials:ro"     \
       -e LOCATION=nl                        \
       -e MAX_LOAD=20                        \
       -e RECREATE_VPN_CRON="*/30 * * * *"   \
       -e NETWORK="$(route -n get default | grep 'gateway' | awk '{print $2}')" \
       -e PROTOCOL=udp                       \
       ivonet/nordvpn:latest


#run                                   \  run
#-it                                   \  in interactive tty mode
#--rm                                  \  remove yourself when closed down
#--cap-add=NET_ADMIN                   \  be net admin
#--device /dev/net/tun                 \  and use the tun device
#--name nordvpn                        \  call yourself nordvpn
#-v "$(pwd)/ovpn:/ovpn"                \  mount local volume in current directory/ovpn to internal /ovpn
#-v "$(pwd)/creds:/credentials:ro"     \  mount local volume in current directory/creds to internal /credentials in read only mode
#-e LOCATION=nl                        \  env var LOCATION set to The Netherlands
#-e MAX_LOAD=20                        \  how much may the server already be taxed - Default 30 percent
#-e RECREATE_VPN_CRON="*/30 * * * *"   \  cron job directive for getting new IP by reconnecting vpn server every 30 minuts
#-e PROTOCOL=tcp                       \  protocol either tcp or udp - remove will choose random
#ivonet/nordvpn:latest


docker run                                 \
       -it                                 \
       --rm                                \
       --cap-add=NET_ADMIN                 \
       --device /dev/net/tun               \
       --name vpn                        \
       -v "$(pwd)/ovpn:/ovpn"              \
       -v "$(pwd)/creds:/credentials:ro"   \
       -p 8118:8118                        \
       -p 9500:9500                        \
       -e MAX_LOAD=50                      \
       -e LOCATION=nl                      \
       -e PROTOCOL=tcp                     \
       -e RECREATE_VPN_CRON="*/1 * * * *"   \
       ivonet/nordvpn:latest
