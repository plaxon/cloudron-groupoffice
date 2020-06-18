#!/bin/bash

set -eu

mkdir -p /run/app/sessions
mkdir -p /app/data/groupoffice

cp /app/code/config.php.tpl /app/data/config.php

sed -i 's/{dbHost}/'${CLOUDRON_MYSQL_HOST}'/' /app/data/config.php
sed -i 's/{dbName}/'${CLOUDRON_MYSQL_DATABASE}'/' /app/data/config.php
sed -i 's/{dbUser}/'${CLOUDRON_MYSQL_USERNAME}'/' /app/data/config.php
sed -i 's/{dbPass}/'${CLOUDRON_MYSQL_PASSWORD}'/' /app/data/config.php

ln -sf /etc/groupoffice/config.php /app/data/config.php

APACHE_CONFDIR="" source /etc/apache2/envvars
rm -f "${APACHE_PID_FILE}"
exec /usr/sbin/apache2 -DFOREGROUND