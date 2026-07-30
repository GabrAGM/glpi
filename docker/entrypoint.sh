#!/bin/bash
set -e

# Set timezone
if [ -n "${TIMEZONE}" ]; then
    echo "date.timezone = ${TIMEZONE}" > /etc/php/8.3/apache2/conf.d/99-timezone.ini
    echo "date.timezone = ${TIMEZONE}" > /etc/php/8.3/cli/conf.d/99-timezone.ini
fi

# PHP security
for cfg in /etc/php/8.3/apache2/php.ini /etc/php/8.3/cli/php.ini; do
    [ -f "$cfg" ] && sed -i 's/^;session.cookie_httponly.*/session.cookie_httponly = on/' "$cfg"
done

# LDAP: disable cert validation (common in internal AD environments)
if ! grep -q "TLS_REQCERT" /etc/ldap/ldap.conf 2>/dev/null; then
    echo "TLS_REQCERT never" >> /etc/ldap/ldap.conf
fi

# Cron job for GLPI scheduler (every 2 minutes)
# ENABLE_CRON=false lets this container's cron be disabled once an external
# scheduler (e.g. an ECS scheduled task) runs front/cron.php instead, so it
# no longer competes with Apache for CPU on the web container.
if [ "${ENABLE_CRON:-true}" = "true" ]; then
    CRON_LINE="*/2 * * * * www-data /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null"
    if ! grep -qF "glpi/front/cron.php" /etc/cron.d/glpi 2>/dev/null; then
        echo "$CRON_LINE" > /etc/cron.d/glpi
        chmod 644 /etc/cron.d/glpi
    fi
    service cron start
fi

# Ensure proper permissions on runtime dirs
chown -R www-data:www-data /var/www/html/glpi/files

# Start Apache
a2enmod rewrite headers > /dev/null 2>&1
rm -f /var/run/apache2/apache2.pid
exec apache2ctl -D FOREGROUND
