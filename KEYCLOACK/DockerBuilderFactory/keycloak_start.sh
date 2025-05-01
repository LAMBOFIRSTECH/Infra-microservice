#!/bin/bash

# Charger les variables d'environnement à partir du fichier .env
export $(grep -v '^#' /opt/keycloak/.env | xargs)
sed -i "s|db-username={DB_USERNAME}|db-username=${KC_DB_USERNAME}|g" /opt/keycloak/conf/keycloak.conf
sed -i "s|db-password={DB_PASSWORD}|db-password=${KC_DB_PASSWORD}|g" /opt/keycloak/conf/keycloak.conf

if [[ -z "$KC_DB_USERNAME" || -z "$KC_DB_PASSWORD" ]]; then
  echo "Erreur: les variables d'environnement DB_USERNAME et DB_PASSWORD doivent être définies."
  exit 1
fi
# Démarrer supervisord
exec /usr/bin/supervisord -c /etc/supervisord.conf