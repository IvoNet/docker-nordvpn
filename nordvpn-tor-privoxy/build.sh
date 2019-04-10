#!/usr/bin/env bash
image=nordvpn-tor-privoxy
version=1.1-0.3.4.11-3.0.26

deploy="false"
#deploy="true"
versioning=false
#versioning=true

#OPTIONS="--no-cache --force-rm"
#OPTIONS="--no-cache"
#OPTIONS="--force-rm"
OPTIONS=""

docker build ${OPTIONS} -t ivonet/${image}:latest .
if [ "$?" -eq 0 ] && [ ${deploy} == "true" ]; then
    docker push ivonet/${image}:latest
fi

if [ "$versioning" == "true" ]; then
    docker tag ivonet/${image}:latest ivonet/${image}:${version}
    if [ "$?" -eq 0 ] && [ ${deploy} == "true" ]; then
        docker push ivonet/${image}:${version}
    fi
fi



