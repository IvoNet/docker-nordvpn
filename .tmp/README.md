# NordVPN

A NordVPN docker image.

## Usage

```bash
docker run -d \
   --restart unless-stopped \
   --cap-add=NET_ADMIN \
   --device /dev/net/tun \
   --name vpn \
   -v "$(pwd)/ovpn:/ovpn" \
   -v "$(pwd)/creds:/credentials" \
   -e USER=USER_HERE \
   -e PASS=PASSWORD_HERE \
   -e MAX_LOAD=10 \
   -e RECREATE_VPN_CRON="*/30 * * * *" \
   -e PROTOCOL=openvpn_tcp \
   ivonet/nordvpn:latest
```

put a file named `credentials.txt` in the mounted `credentials` folder with your credentials in it.
with the username on the first line and the password on the second line.
This can be done if you don't like to add the environment variables (below) in the run command.

```bash
   -e USER=USER_HERE \
   -e PASS=PASSWORD_HERE \
```

Other examples can be found as shell scripts in this folder

## API

* [Server stats](https://nordvpn.com/api/server/stats)
* [Server metadata](https://api.nordvpn.com/server) 
* [Recommended servers](https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations)
* [User IP Address](https://api.nordvpn.com/user/address)
* [Config files (zipv2)](https://api.nordvpn.com/files/zipv2)
* [DNS Smart](https://api.nordvpn.com/dns/smart)

## Todo

- Add proxy server to it
    - [privoxy](https://www.privoxy.org/user-manual/installation.html)



## Dump

```bash
curl -s https://api.nordvpn.com/server | jq -c '.[] | .country' | jq -s -a -c 'unique | .[]'
curl -s https://api.nordvpn.com/server | jq -c '.[] | .categories[].name' | jq -s -a -c 'unique | .[]'
```

- https://www.linode.com/docs/networking/vpn/set-up-a-hardened-openvpn-server/
- https://support.nordvpn.com/Connectivity/Linux/1047409212/How-to-disable-IPv6-on-Linux.htm
- https://nordvpn.com/nl/tutorials/padavan/openvpn/
- https://www.instructables.com/id/Raspberry-Pi-VPN-Gateway/
- https://linuxconfig.org/how-to-create-a-vpn-killswitch-using-iptables-on-linux


API_RECOMMENDED_SERVERS="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations" \
