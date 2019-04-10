#!/usr/bin/with-contenv bash

cron_dir="/var/spool/cron/crontabs"
cron_file="$cron_dir/root"

rm -f "$cron_file"
touch "$cron_file"

if [[ "${RECREATE_VPN_CRON}" ]]; then
    echo "Create cron job..."
    echo "$RECREATE_VPN_CRON /usr/local/bin/python /etc/cont-init.d/60-create-vpn-config.py && /bin/s6-svc -h /var/run/s6/services/nordvpnd" >> "$cron_file"
fi

exit 0
