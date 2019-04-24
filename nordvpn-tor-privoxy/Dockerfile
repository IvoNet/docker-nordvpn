FROM ivonet/nordvpn:latest

RUN apk --update --no-cache --no-progress add privoxy tor

EXPOSE 8118 9050

COPY root/ /

