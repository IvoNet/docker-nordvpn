# Alpine s6 overlay init system

Base image.

## Specs

- Alpine 3.9
- Python 3
- [s6-overlay](https://github.com/just-containers/s6-overlay)

## Usage

This image is a base image with a simple init system already ready for use.

if you create a directory structure looking like te one below where the files in the cont-init.d folder 
can be anything you want as long as it is executable you have a system to init your environment

```text
  root
├──   etc
│  ├──   cont-finish.d
│  ├──   cont-init.d
│  │  ├──   10-first.sh
│  │  ├──   20-second.sh
│  │  ├──   30-third.py
│  └──   services.d
│     ├──   crond
│     │  └──   run
│     └──   nordvpnd
│        └──   run
└──   usr
   └──   local
      └──   lib
         └──   python3.7
            └──   site-packages
               └──   IvoNet
                  └──   __init__.py
```                     
copy the folder into your onw image based on this one like this

```dockerfile
FROM alpine-python-s6:latest
COPY root/ /
```

and of course any other thing you want.to configure..

in summary:
- create a cont-init.d folder with in it files to configure your system and COPY that to the /etc folder
- create run scripts for your "services" and place them in the etc/services.d folder in its own subdir
 
The reason I choose for a python alpine image is just that I'm much better in Python than bash scripting 
so now I have the choice :-) 
 
## Example services.d script

### Cron

in `/etc/services.d/crond` create a `run` file with the following content:

```bash
#!/usr/bin/with-contenv sh

exec /usr/sbin/crond -f -l 8 -d 6
```

# Documentation

* [s6-overlay](https://github.com/just-containers/s6-overlay)


# Example usage

* See [ivonet/nordvpn](http://ivo2u.nl/on) for an example using this base image
