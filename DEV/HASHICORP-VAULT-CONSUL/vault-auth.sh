#!/bin/bash

colors() {
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    CYAN="\033[1;36m"
    NC="\033[0m" # Réinitialisation
    printf "${!1}${2} ${NC}\n"
}
rootToken=$(cat token.txt)
vault login $rootToken # C'est le token principal qui permet d'avoir tous les accès et effectuer toutes opérations sur Vault

# Activee l'authentification approle
vault auth enable approle
# Activer le moteur de secrets KV v2
vault secrets enable -path=kv-v2 kv-v2
vault secrets enable -path=secret kv

# Créer une politique d'authentification qui va posséder toutes les politiques
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

# Appliquer la politique
vault policy write admin root-policy.hcl

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
# Appliquer la politique sous le nom external-services
vault policy write external-services appRole-policy.hcl

# Création du role et association du role (dotnet-role) au nom de politique (external-services)
vault write auth/approle/role/dotnet-role policies="external-services,kv-v2"

# Récupérer le role_id pour l'authentification AppRole
ROLE_ID=$(vault read -field=role_id auth/approle/role/dotnet-role/role-id)
# Création du secret_id associé à ce role_id Nb : il n'est pas automatiquement créé une fois que le role est créé
SECRET_ID=$(vault write -force auth/approle/role/dotnet-role/secret-id | grep -m 1 '^secret_id' | awk '{print $2}')

echo $ROLE_ID > /vault/data/role-id-file
echo $SECRET_ID > /vault/data/secret-id-file

sleep 15

# Stocke les crédentials pour auth/approle/role/dotnet-role dans vault
vault kv put secret/approle credentials="role_id=$ROLE_ID secret_id=$SECRET_ID"
echo $?  # Affiche le code de retour de la commande précédente
echo "--------------------------------------------------------"
# Vérifier l'authentification
if [ -z "$rootToken" ]; then
    echo "Erreur d'authentification. Le token est vide."
    exit 1
else
    echo "Authentification réussie"
fi

# Chaine de connection à RabbitMQ
vault kv put kv-v2/secret/rabbit-connection rabbitMqConnectionString='admin:password$1@172.17.0.2:5672'
# Vérifier que la valeur a bien été ajoutée et stockée dans Vault
vault kv get kv-v2/secret/rabbit-connection

# Mot de passe ldap
vault kv put kv-v2/secret/ldap-pass ldapPassword=$(printf "password\\$1")
vault kv get kv-v2/secret/ldap-pass

if [[ $? -ne 0 ]]; then
    colors "RED" "Échec lors de l'authentification vault."
    exit 1
fi

colors "GREEN" "Terminer avec succès."
