#!/usr/bin/env bash

#docker exec $(docker ps |grep vpn|awk '{print $1}') curl -s https://ipecho.net/plain

docker exec nordvpn curl -s https://ipecho.net/plain
