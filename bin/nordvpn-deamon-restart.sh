#!/usr/bin/env bash


docker run                                   \
       -d                                    \
       --cap-add=NET_ADMIN                   \
       --device /dev/net/tun                 \
       --name nordvpn-deamon                 \
       -v "$(pwd)/ovpn:/ovpn"                \
       -v "$(pwd)/creds:/credentials:ro"     \
       -p 8118:8118                          \
       -e MAX_LOAD=10                        \
       -e RECREATE_VPN_CRON="*/2 * * * *"    \
       --restart unless-stopped              \
       ivonet/nordvpn:latest

#run                                   \ # run
#-d                                    \ # in deamon mode
#--cap-add=NET_ADMIN                   \ # be net admin
#--device /dev/net/tun                 \ # and use the tun device
#--name nordvpn-deamon                 \ # call yourself nordvpn-daemon
#-v "$(pwd)/ovpn:/ovpn"                \ # mount local volume in current directory/ovpn to internal /ovpn
#-v "$(pwd)/creds:/credentials:ro"     \ # mount local volume in current directory/creds to internal /credentials in read only mode
#-p 8118:8118                          \ # expose port 8118 for connecting containers
#-e MAX_LOAD=10                        \ # how much may the server already be taxed - Default 30 percent
#-e RECREATE_VPN_CRON="*/2 * * * *"    \ # restart every 2 minutes
#--restart unless-stopped              \ # restart the container unless stopped
