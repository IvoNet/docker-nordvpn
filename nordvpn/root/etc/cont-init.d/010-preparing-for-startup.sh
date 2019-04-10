#!/usr/bin/with-contenv bash

echo "Setting volume rights..."
chmod -R 644 /ovpn

echo "Creating necessary folders ..."
mkdir /tmp 2>/dev/null

exit 0
