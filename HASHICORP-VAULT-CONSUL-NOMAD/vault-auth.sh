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
rootToken=$(cat token.txt)
# Vérifier l'authentification
if [ -z "$rootToken" ]; then
  colors "RED" "💥 Erreur d'authentification. Le token est vide."
  exit 1
fi
colors "GREEN" "🚀 Token trouvé authentification réussie"

vault login $rootToken
function start_motors() {

  # Activee l'authentification approle
  vault auth enable approle
  # Activer le moteur de secrets KV v2
  vault secrets enable -path=kv-v2 kv-v2
  vault secrets enable -path=secret kv
  # Active le moteur de secrets PostgreSQL
  vault secrets enable database
}

function generate_vault_policies() {

  # Créer une politique d'authentification pour le role admin qui va posséder toutes les politiques
  cat <<EOF >root-policy.hcl
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "kv-v2/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/approle/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "auth/approle/login" {
  capabilities = ["create", "update"]
}
EOF
  # Créer une politique pour le mot de passe dynamique dans postgres pour le user keycloak_service
  cat <<EOF >vault_postgres-policy.hcl
path "database/static-creds/vault_postgres" {
  capabilities = ["read"]
}
path "database/rotate-role/vault_postgres" {
  capabilities = ["update"]
}
EOF

  # Créer une politique pour le mot de passe dynamique dans mongo pour le user gravitee_service
  cat <<EOF >vault_mongo-policy.hcl
path "database/static-creds/vault_mongo" {
  capabilities = ["read"]
}

path "database/rotate-role/vault_mongo" {
  capabilities = ["update"]
}

path "database/static-roles/vault_mongo" {
  capabilities = ["read", "create", "update"]
}
EOF

  # Créer une politique pour l'authentification des services externes à vault
  cat <<EOF >appRole-policy.hcl
path "secret/approle/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "kv-v2/*" {
  capabilities = ["create", "read", "update"]
}
path "auth/approle/login" {
  capabilities = ["create", "update","read"]
}
EOF
}

function get_application_credentials() {

  # Création du role et association du role (dotnet-role) au nom de politique (external-services)
  vault write auth/approle/role/dotnet-role policies="external-services,kv-v2"
  # Récupérer le role_id pour l'authentification AppRole
  ROLE_ID=$(vault read -field=role_id auth/approle/role/dotnet-role/role-id)
  # Création du secret_id associé à ce role_id Nb : il n'est pas automatiquement créé une fois que le role est créé
  SECRET_ID=$(vault write -force auth/approle/role/dotnet-role/secret-id | grep -m 1 '^secret_id' | awk '{print $2}')

  echo $ROLE_ID >/vault/data/role-id-file
  echo $SECRET_ID >/vault/data/secret-id-file
  sleep 15
  # Stocke les crédentials pour auth/approle/role/dotnet-role dans vault
  vault kv put secret/approle credentials="role_id=$ROLE_ID secret_id=$SECRET_ID"
  vault kv put kv-v2/secret/rabbit-connection rabbitMqConnectionString='admin:password$1@172.17.0.2:5672'
  # Chaine de connection à RabbitMQ
  vault kv get kv-v2/secret/rabbit-connection

  # Mot de passe ldap
  vault kv put kv-v2/secret/ldap-pass ldapPassword=$(printf "password\\$1")
  vault kv get kv-v2/secret/ldap-pass
}

function renew_keycloak_password() {
  ### WARNING LA CONNEXION EST EN MODE SSL DISABLE PASSER A TRUE QUAND ON AURA G2RER LES CERTIFICATS
  colors "YELLOW" "⏳ Tentative de connexion à postgres et mise à jour du mot de passe de keycloak_service."
  vault write database/config/keycloak_db \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="vault_postgres" \
    connection_url="postgresql://{{username}}:{{password}}@postgres:5432/keycloak_db?sslmode=disable" \
    username="vault_admin" \
    password="1234" \
    password_authentication="scram-sha-256"

  vault write database/static-roles/vault_postgres \
    db_name="keycloak_db" \
    rotation_statements="ALTER ROLE keycloak_service WITH PASSWORD '{{password}}';" \
    username="keycloak_service" \
    rotation_period="24h"

  if [[ $? -ne 0 ]]; then
    colors "RED" "❌ Échec de configuration dans vault."
    exit 1
  fi

  KEYCLOAK_PASS=$(vault read database/static-creds/vault_postgres | grep password | awk '{print $NF}')
  if [[ $? -ne 0 ]]; then
    colors "RED" "🚫 Vault n'a pas pu récupérer le mot de passe de keycloak_service."
    exit 1
  fi
  mkdir -p /vault/shared
  colors "YELLOW" "🔐 sauvegarde du mot de passe keycloak_service dans le dossier partagé"
  echo "KEYCLOAK_PASS=$KEYCLOAK_PASS" >/vault/shared/services_pass.txt
}

function renew_gravitee_password() {
  ################### proxy.infra.docker:27018 (Proxy envoy)##### Pas de tls_certificate_key=@/opt/vault/tls/backend.pem à moins que mongo demande pb de mutualité
  colors "YELLOW" "⏳ Tentative de connexion à mongodb et mise à jour du mot de passe de gravitee_service."

  # ╔══════════════════════════════════════════════════╗
  # ║Configuration pour bd MongoDb-Gravitee_db         ║
  # ╚══════════════════════════════════════════════════╝
  vault write database/config/gravitee_db \
    plugin_name=mongodb-database-plugin \
    allowed_roles="vault_mongo" \
    connection_url="mongodb://{{username}}:{{password}}@proxy.infra.docker:27018/gravitee_db?authSource=gravitee_db&authMechanism=SCRAM-SHA-256" \
    tls_ca=@/opt/vault/tls/vault-ca.crt \
    username="vault_admin" \
    password="1234"

  vault write database/static-roles/vault_mongo \
    db_name="gravitee_db" \
    username="gravitee_service" \
    rotation_statements='db.changeUserPassword("gravitee_service", "{{password}}")' \
    rotation_period="24h"

  # ╔══════════════════════════════════════════════════╗
  # ║Configuration pour bd MongoDb-Gravitee_analytics  ║
  # ╚══════════════════════════════════════════════════╝
  vault write database/config/gravitee_analytics \
    plugin_name=mongodb-database-plugin \
    allowed_roles="vault_mongo" \
    connection_url="mongodb://{{username}}:{{password}}@proxy.infra.docker:27018/gravitee_analytics?authSource=gravitee_analytics&authMechanism=SCRAM-SHA-256" \
    tls_ca=@/opt/vault/tls/vault-ca.crt \
    username="vault_admin" \
    password="1234"
    
  vault write database/static-roles/vault_mongo \
    db_name="gravitee_analytics" \
    username="gravitee_service" \
    rotation_statements='db.changeUserPassword("gravitee_service", "{{password}}")' \
    rotation_period="24h"

  GRAVITEE_PASS=$(vault read database/static-creds/vault_mongo | grep password | awk '{print $NF}')
  if [[ $? -ne 0 ]]; then
    colors "RED" "🚫 Vault n'a pas pu récupérer le mot de passe de gravitee_service."
    exit 1
  fi
  colors "YELLOW" "🔐 sauvegarde du mot de passe gravitee_service dans le dossier partagé"
  echo "GRAVITEE_PASS=$GRAVITEE_PASS" >>/vault/shared/services_pass.txt
}
main() {
  start_motors
  generate_vault_policies
  # Appliquer la politique au role admin
  vault policy write admin root-policy.hcl
  # Appliquer la politique au role vault_postgres
  vault policy write vault_postgres vault_postgres-policy.hcl
  # Appliquer la politique au role vault_mongo
  vault policy write vault_mongo vault_mongo-policy.hcl
  # Appliquer la politique sous le nom external-services
  vault policy write external-services appRole-policy.hcl

  get_application_credentials
  # pas besoin de ceux du bas pour les tests en local
  # renew_keycloak_password 
  # renew_gravitee_password

  colors "CYAN" "🧹 Suppression des fichiers confidentiels. (Token de connexion de vault)"
  rm token.txt
  if [[ $? -ne 0 ]]; then
    colors "RED" "🧹 Vault n'a pas pu supprimer les fichiers confidentiels."
    exit 1
  fi
  colors "GREEN" "🏁 Configuration terminée avec succès."
}
main
