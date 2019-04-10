#!/usr/bin/with-contenv bash

echo "Cleaning up..."
rm -rf /var/log/  2>/dev/null
rm -rf /tmp/      2>/dev/null
mkdir /tmp        2>/dev/null

exit 0
