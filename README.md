# docker-nordvpn

[NordVPN](https://nordvpn.com/) docker image.

This is a NordVPN client docker container that uses nordvpn servers based on location, load and protocol. 
It makes routing containers' traffic through OpenVPN easy.

## Credentials

important note: The NordVPN use of credentials have recently changed without telling users!


You can find your service credentials by following these steps:

- Please log in to your Nord Account by following this [link](https://my.nordaccount.com/dashboard/nordvpn/)
- Click on the NordVPN tab on the left panel which is under the Services tab.
- Scroll down and locate the Manual Setup tab, then click on Set up NordVPN manually:
- Verify your email by entering the one-time code you will receive in your registered email inbox. If you are unable to find the email, please make sure to also check your spam/junk folder.
- Copy your service credentials by using the buttons on the right.
- when this token is created a new username and password is also created on the same page.
- replace the username and password in the credentials.txt file with the new ones.
- restart the container

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


# Environment variables

| Environment Variable                  | Description                                             |
| :-------------------------------------| :-------------------------------------------------------|
| USER     | Username |
| PASS     | Password |
| MAX_LOAD | Only allow servers with a load less then the given percentage. Defaults to 30|
| LOCATION | Two letter country code to direct the filtering to a specific country  |
| PROTOCOL | tcp/udp |
| NETWORK  | Classless Inter-Domain Routing (IE 192.168.1.0/24), to allows replies once the VPN is up. |
| NETWORK6 | Classless Inter-Domain Routing (IE fe00:d34d:b33f::/64), to allows replies once the VPN is up. |
| URL_OVPN_FILES | endpoint to the NordVPN ovpn files (https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip) |
| API_SERVER_STATS | endpoint to the NordVPN server stats (https://nordvpn.com/api/server/stats) | 
| API_SERVER | endpoint to the Api Server of NordVPN (https://nordvpn.com/api/server) |

Please read the Credentials section if you do not want to add the USER/PASS credentials to the commandline. 

# Credentials

if you use the `-v "$(pwd)/creds:/credentials"` option in the run command of one if the images
you need to create a file in this directory called `credentials.txt` and
give it the following content:

credentials.txt:
```bash
USERNAME_HERE
PASSWORD_HERE
```

# Release notes
The versioning of the images seems very long and convoluted but is quite logical when explained :-)
Per image the format will be explained

## ivonet/nordvpn

Format: `<major version>.<minor version>`

- when api breaking changes occur the major version will be updated and the minor version reset
- when bug fixes or non api breaking changes occur the minor version is incremented

### 2.0

- Upgraded packages and general cleanup
- Python version 3.9.5
- s6 version 2.2.0.3

### 1.4
- Added a HOME variable for tor

### 1.3
- Removed chmod attribute change on startup for the volume as it is probably almost never needed and takes a long time if lots of ovpn files are placed in the volume.
- updated and released the other images too based omn this one.
- now the other images will build of latest as that will make life a bit more easy.

### 1.1 and 1.2
- fixes due to findings when building the other images

### 1.0
- first fully working version

## ivonet/nordvpn-privoxy

Format: `<My nordvpn image version>-<Privoxy version used>`

So 1.3-3.0.26 means:
- Version 1.3 of ivonet/nordvpn
- version 3.0.26 of privoxy

### 2.0-3.0.32

- Upgraded parent image
- Upgraded privoxy proxy to version 3.0.32

## ivonet/nordvpn-tor-privoxy

Format: `<My nordvpn image version>-<Tor version used>-<Privoxy version used>`

So 1.3-0.3.4.11-3.0.26 means:
- Version 1.3 of ivonet/nordvpn
- version 0.3.4.11 of tor
- version 3.0.26 of privoxy

### 2.0-0.4.4.9-3.0.32

- Upgraded parent image
- Upgraded to tor version 0.4.4.9
