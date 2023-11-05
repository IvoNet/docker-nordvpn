#!/usr/bin/env bash
mkdir -p root/etc/cont-init.d
mkdir -p root/etc/cont-finish.d
mkdir -p root/etc/services.d/a-service

cat <<'EOT' > root/startapp.sh
#!/usr/bin/env bash
while true;
do
  # Your application startup here
done
EOT

cat <<'EOT' > root/cont-init.d/100-init.sh
#!/usr/bin/with-contenv bash
# Add your commands here
EOT

cat <<'EOT' > root/services/a-service/run
#!/usr/bin/with-contenv bash
exec 2>&1
exec #your service startup here
EOT
