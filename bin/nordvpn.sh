#!/usr/bin/env bash

docker run                                   \ # run
       -it                                   \ # in interactive tty mode
       --rm                                  \ # remove yourself when closed down
       --cap-add=NET_ADMIN                   \ # be net admin
       --device /dev/net/tun                 \ # and use the tun device
       --name nordvpn                        \ # call yourself nordvpn
       -v "$(pwd)/ovpn:/ovpn"                \ # mount local volume in current directory/ovpn to internal /ovpn
       -v "$(pwd)/creds:/credentials:ro"     \ # mount local volume in current directory/creds to internal /credentials in read only mode
       -e LOCATION=nl                        \ # env var LOCATION set to The Netherlands
       -e MAX_LOAD=20                        \ # how much may the server already be taxed - Default 30 percent
       -e RECREATE_VPN_CRON="*/30 * * * *"   \ # cron job directive for getting new IP by reconnecting vpn server every 30 minuts
       -e PROTOCOL=tcp                       \ # protocol either tcp or udp - remove will choose random
       ivonet/nordvpn:latest
