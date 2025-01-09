#!/usr/bin/env bash

mkdir -p root/etc/s6-overlay/s6-rc.d/user/contents.d

#ask for service name
echo "Enter the name of the service you want to create (e.g. myservice):"
read SERVICE_NAME
if [ -z "$SERVICE_NAME" ]; then
    echo "Service name cannot be empty"
    exit 1
fi
mkdir -p root/etc/s6-overlay/s6-rc.d/$SERVICE_NAME/dependencies.d
echo "#!/command/with-contenv bash" > root/etc/s6-overlay/s6-rc.d/$SERVICE_NAME/run
echo "/etc/s6-overlay/s6-rc.d/$SERVICE_NAME/run" > root/etc/s6-overlay/s6-rc.d/$SERVICE_NAME/up
touch root/etc/s6-overlay/s6-rc.d/$SERVICE_NAME/dependencies.d/base
echo "longrun/oneshot" > root/etc/s6-overlay/s6-rc.d/$SERVICE_NAME/type
touch root/etc/s6-overlay/s6-rc.d/user/contents.d/$SERVICE_NAME
