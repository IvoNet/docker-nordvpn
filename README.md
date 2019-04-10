# docker-nordvpn

[NordVPN](https://nordvpn.com/) docker image.

This is a NordVPN client docker container that uses nordvpn servers based on location, load and protocol. 
It makes routing containers' traffic through OpenVPN easy.

## Usage

See the `bin` folder for run command examples


# Images

## ivonet/nordvpn

is the base image for all the other containers. It is the fully configured 
nordvpn client and can be used on its own merit.

### run it...

The command below would run the nordvpn client with a reload schedule of 30 minutes, on a Dutch server with a max load of 20%.
The protocol wanted is idp and the local network is mapped.

```bash
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
```

Note that this (`route -n get default | grep 'gateway' | awk '{print $2}'`) command is based on a MacOS host system
If you use a *ix based system you might want to change that command to something like `ip route | grep -v default | awk '{print $1}'`
or `ip route | awk '!/ (docker0|br-)/ && /src/ {print $1}'`

now you can connect to this container with other containers like this

```bash
docker run -ti --rm --net=container:nordvpn YOUR_IMAGE_HERE
```

For more examples see the bin folder of the source project

## ivonet/nordvpn-privoxy

With ivonet/nordvpn as the base image for this privoxy image it becomes a proxy server with a vpn connection to proxy through.
Very handy if you want a proxy for your browser (use foxy proxy plugin or somesuch) that also removes lots of adds and the like.

### run it ...

Well it is kinda the same as in the nordvpn example but now it also exposes port 8118 to which you can point your proxy to
get access to a add blocking proxy running on a vpn.

```bash
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
```

## ivonet/nordvpn-tor-privoxy

Lets go another step further and add tor to it for added privacy. 

### run it ...

Now it will run the privoxy proxy over a the tor network over the vpn.

```bash
docker run                                 \
       -it                                 \
       --rm                                \
       --cap-add=NET_ADMIN                 \
       --device /dev/net/tun               \
       --name proxy                        \
       -v "$(pwd)/ovpn:/ovpn"              \
       -v "$(pwd)/creds:/credentials:ro"   \
       -p 8118:8118                        \
       -p 9500:9500                        \
       -e MAX_LOAD=10                      \
       -e LOCATION=nl                      \
       -e PROTOCOL=tcp                     \
       ivonet/nordvpn-tor-privoxy:latest
```
