#!/bin/bash

set -eu

mkdir -p /run/app/sessions

cp /etc/groupoffice/config.php.tpl /etc/groupoffice/config.php

sed -i 's/{dbHost}/'${CLOUDRON_MYSQL_HOST}'/' /etc/groupoffice/config.php
sed -i 's/{dbName}/'${CLOUDRON_MYSQL_DATABASE}'/' /etc/groupoffice/config.php
sed -i 's/{dbUser}/'${CLOUDRON_MYSQL_USERNAME}'/' /etc/groupoffice/config.php
sed -i 's/{dbPass}/'${CLOUDRON_MYSQL_PASSWORD}'/' /etc/groupoffice/config.php

APACHE_CONFDIR="" source /etc/apache2/envvars
rm -f "${APACHE_PID_FILE}"
exec /usr/sbin/apache2 -DFOREGROUND