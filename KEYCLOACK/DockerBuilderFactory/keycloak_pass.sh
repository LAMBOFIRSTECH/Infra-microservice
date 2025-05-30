#!/bin/bash

# Définir les couleurs
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

# Vérifier si Vault est accessible
CHECK_VAULT_SERVER=$(curl -s -L -k -o /dev/null -w "%{http_code}" "https://172.28.0.6:8200/v1/sys/health")

if [[ "$CHECK_VAULT_SERVER" != "200" && "$CHECK_VAULT_SERVER" != "302" ]]; then
    colors "RED" "Erreur : Le serveur Vault est inaccessible. Code HTTP: $CHECK_VAULT_SERVER"
    exit 1
fi

# Vérifier état Vault
curl --silent -k --max-time 90 https://172.28.0.6:8200/v1/sys/health \
  | grep -o '"\(initialized\|sealed\)":\([^,}]*\)' > vault_status.txt

vault_init_status=$(grep initialized vault_status.txt | cut -d ':' -f2 | tr -d ' ",')
vault_lock=$(grep sealed vault_status.txt | cut -d ':' -f2 | tr -d ' ",')

if [[ "$vault_init_status" != "true" || "$vault_lock" != "false" ]]; then
    colors "RED" "Erreur : Le service Vault n'est pas initialisé ou est scellé."
    exit 1
fi

# Préparation pour substitution
CONFIG_FILE="/opt/keycloak/conf/keycloak.conf"
PASSWORD_FILE="/opt/shared/db_password.txt"
TEMPLATE_FILE="/opt/keycloak/conf/keycloak.conf.template"

if [ ! -f "$CONFIG_FILE" ]; then
    colors "RED" "❌ Fichier de configuration introuvable : $CONFIG_FILE"
    exit 1
fi

colors "CYAN" "🔐 En attente du mot de passe dans $PASSWORD_FILE..."

# Attendre que le mot de passe arrive
while [ ! -f "$PASSWORD_FILE" ]; do
    echo "⏳ En attente du mot de passe..."
    sleep 10
done

# Lire et substituer
PASSWORD=$(cat "$PASSWORD_FILE")
KC_HTTP_RELATIVE_PATH="/cloak"
hostname="develop.lamboft.it"

sed "s|{{DB_PASSWORD}}|$PASSWORD|g" "$TEMPLATE_FILE" > "$CONFIG_FILE"
sed "s|{{KEYCLOAK_PATH_CONTEXT}}|$KC_HTTP_RELATIVE_PATH|g" "$TEMPLATE_FILE" > "$CONFIG_FILE"
sed "s|{{HOSTNAME}}|$hostname|g" "$TEMPLATE_FILE" > "$CONFIG_FILE"

if [[ $? -ne 0 ]]; then
    colors "RED" "❌ Échec de la substitution du mot de passe."
    exit 1
fi
rm /opt/keycloak/vault_status.txt
rm /opt/shared/db_password.txt
colors "GREEN" "✅ Mot de passe mis à jour dans $CONFIG_FILE"
exec /opt/keycloak/bin/kc.sh start