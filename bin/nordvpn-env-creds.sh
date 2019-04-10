#!/usr/bin/env bash

read -s    "Usr: " USER
read -s -p "Pwd: " PASS

docker run                                \ 
       -it                                \
       --rm                               \
       --cap-add=NET_ADMIN                \
       --device /dev/net/tun              \
       --name nordvpn-env-creds           \
       -v $(pwd)/ovpn:/ovpn               \
       -e USER=$USER                      \
       -e PASS=$PASS                      \
       -e LOCATION=nl                     \
       -e MAX_LOAD=10                     \
       -e RECREATE_VPN_CRON="* * * * *"   \
       ivonet/nordvpn:latest

#run                                \ # run
#-it                                \ # in interactive tty mode
#--rm                               \ # remove yourself when closed down
#--cap-add=NET_ADMIN                \ # be net admin
#--device /dev/net/tun              \ # and use the tun device
#--name nordvpn-env-creds           \ # call yourself nordvpn-env-creds
#-v $(pwd)/ovpn:/ovpn               \ # mount local volume in current directory/ovpn to internal /ovpn
#-e USER=$USER                      \ # env var USER for username
#-e PASS=$PASS                      \ # env var PASS for password
#-e LOCATION=nl                     \ # env var LOCATION set to The Netherlands
#-e MAX_LOAD=10                     \ # how much may the server already be taxed - Default 30 percent
#-e RECREATE_VPN_CRON="* * * * *"   \ # cron job for refreshing every minute - do not do this in prod
