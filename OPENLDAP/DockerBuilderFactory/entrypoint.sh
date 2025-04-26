#!/bin/sh
set -e

echo "[Entrypoint] Préparation des logs et sockets..."

mkdir -p /var/www/logs /var/log/php82 /run/php
chown -R www-data:www-data /var/www/logs /run/php
chmod 755 /var/www/logs
rm -f /run/php/php82-fpm.sock

echo "[Entrypoint] Lancement de supervisord..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
# Voir si on a encore besoin de ça ou tout mettre dans le dockerfile
## sudo docker build -t lambops/phpadminldap:secure . 