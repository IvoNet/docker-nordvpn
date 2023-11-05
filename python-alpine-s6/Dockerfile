FROM python:3.9.16-alpine3.17

LABEL maintainer="IvoNet.nl"

#https://github.com/just-containers/s6-overlay

RUN apk --no-cache --no-progress add bash curl tar xz \
 && curl -s -L "https://github.com/just-containers/s6-overlay/releases/download/v3.1.2.0/s6-overlay-noarch.tar.xz" -o /tmp/s6-overlay-noarch.tar.xz \
 && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
 && curl -s -L "https://github.com/just-containers/s6-overlay/releases/download/v3.1.2.0/s6-overlay-$(uname -m).tar.xz" -o /tmp/s6-overlay-$(uname -m).tar.xz \
 && tar -C / -Jxpf /tmp/s6-overlay-$(uname -m).tar.xz \
 && apk del --purge tar xz \
 && rm -rfv /tmp/*


ENTRYPOINT ["/init"]
