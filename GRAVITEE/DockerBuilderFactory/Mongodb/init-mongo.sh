#!/bin/bash

colors() {
  local COLOR=$1
  local TEXT=$2

  case $COLOR in
  "RED") CODE="\033[0;31m" ;;
  "GREEN") CODE="\033[0;32m" ;;
  "YELLOW") CODE="\033[1;33m" ;;
  "CYAN") CODE="\033[1;36m" ;;
  *) CODE="\033[0m" ;;
  esac

  NC="\033[0m"
  printf "${CODE}%s${NC}\n" "$TEXT"
}
MONGO_ADMIN_PWD="${MONGO_ADMIN_PWD:?Variable MONGO_ADMIN_PWD non définie}"
SSL_OPTS="--ssl --sslPEMKeyFile /opt/mongo/tls/backend.pem --sslCAFile /opt/mongo/tls/vault-ca.crt --host mongo.infra.docker"
echo "[INFO] Waiting for MongoDB to be ready..."

RETRIES=30
until mongo $SSL_OPTS --eval "db.adminCommand('ping')" >/dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "[INFO] Mongo not ready, retrying..."
  RETRIES=$((RETRIES - 1))
  sleep 1
done

if [ $RETRIES -eq 0 ]; then
  echo "[ERROR]  ❌ MongoDB did not become ready in time."
  exit 1
fi

colors "GREEN" "✅ MongoDB is running"
# Vérifier si la base admin a déjà des utilisateurs
getAdminUser=$(
  mongo --host mongo.infra.docker --ssl --sslPEMKeyFile /opt/mongo/tls/backend.pem --sslCAFile /opt/mongo/tls/vault-ca.crt --quiet --eval '
    db = db.getSiblingDB("admin");
    var user = db.getUser("admin");
    printjson(user);
  '
)

cleaned=$(echo "$getAdminUser" | tr -d '\n[:space:]')

if [ "$cleaned" != "null" ]; then
  colors "CYAN" "ℹ️  L'utilisateur 'admin' existe déjà dans la base admin"
  exit 0
fi

colors "YELLOW" "➕ Création du user admin"
createUser=$(
  mongo --host mongo.infra.docker \
    --ssl \
    --sslPEMKeyFile /opt/mongo/tls/backend.pem \
    --sslCAFile /opt/mongo/tls/vault-ca.crt \
    --quiet \
    --eval "db = db.getSiblingDB('admin'); db.createUser({ user: 'admin', pwd: '$MONGO_ADMIN_PWD', roles: [{ role: 'root', db: 'admin' }] });"
)
if [[ $? -ne 0 ]]; then
  colors "RED" "❌ L'utilisateur admin n'a pas été créé"
  exit 1
fi
FILE=/etc/mongod.conf
if [ ! -f "$FILE" ]; then
  colors "RED" "[ERROR] ❌ $FILE n'existe pas."
  exit 1
fi
sed -i 's/^\(\s*authorization:\s*\).*$/\1enabled/' $FILE
if [[ $? -ne 0 ]]; then
  colors "RED" "❌ Erreur de substitution dand le fichier de conf de mongodb."
  exit 1
fi
colors "GREEN" "✅ Initialisation de la bd mongo avec création du user admin terminée avec succès."
supervisorctl restart mongo
