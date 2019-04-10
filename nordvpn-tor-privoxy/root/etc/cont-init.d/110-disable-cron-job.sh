#!/usr/bin/with-contenv bash

cron_dir="/var/spool/cron/crontabs"
cron_file="$cron_dir/root"

rm -f "$cron_file"
touch "$cron_file"

if [[ "${RECREATE_VPN_CRON}" ]]; then
    echo "Cron currently not supported for this image..."
    echo "Removed current cron jobs."
fi

exit 0
