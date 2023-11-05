#!/command/with-contenv bash
###############################################################################
# This script will create a cron job if the correct options are provided
# while creating / running the container.
#
# e.g. -e RECREATE_VPN_CRON="*/2 * * * *"
###############################################################################

cron_dir="/var/spool/cron/crontabs"
cron_file="$cron_dir/root"

rm -f "$cron_file"
touch "$cron_file"

if [[ "${RECREATE_VPN_CRON}" ]]; then
    echo "Create cron job..."
    echo "$RECREATE_VPN_CRON /usr/local/bin/python /etc/cont-init.d/060-create-vpn-config.py && /bin/s6-svc -h /var/run/s6/services/nordvpnd" >> "$cron_file"
fi

exit 0
