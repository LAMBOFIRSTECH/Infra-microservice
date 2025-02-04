#!/bin/sh

export VAULT_ADDR=$VAULT_ADDR
export VAULT_SKIP_VERIFY='true'
echo " Voici l'adresse du serveur Vault --> VAULT_ADDR=$VAULT_ADDR"

# Vérifier si Vault est initialisé
INITIALIZED=$(vault status | grep "Initialized" | awk '{print $2}')
if [ "$INITIALIZED" != "true" ]; then
    echo "Vault is not initialized. Initializing Vault..."
    
    # Initialiser Vault avec 3 clés d'unsealing et un seuil de 2
    vault operator init -key-shares=3 -key-threshold=2 > generated_keys.txt
    
    # Extraire les clés d'unsealing et le token root
    keyArray=$(grep "Unseal Key " generated_keys.txt | cut -c15-)
    rootToken=$(grep "Initial Root Token: " generated_keys.txt | cut -c21-)

    # Sauvegarder le token root dans un fichier sécurisé
    echo $rootToken > root_token.txt
    chmod 600 root_token.txt

    # Afficher les clés d'unsealing et le token root (assurez-vous de les sauvegarder)
    echo "Unseal Keys:"
    for key in $keyArray; do
        echo $key
    done
    echo "Root Token: $rootToken"
    
    # Exporter le token root pour l'utiliser
    export VAULT_TOKEN=$rootToken

    # Déverrouiller Vault
    for key in $keyArray; do
        vault operator unseal $key
    done
    
    # Vérifier que Vault est bien déverrouillé (unsealed)
    if [ "$(vault status | grep "Sealed" | awk '{print $2}')" == "true" ]; then
        echo "1- Vault est scellé."
        exit 1
    else
        echo "1- Vault est dégelé. Tout est prêt!"
    fi

    vault login $rootToken

else
    echo "Vault is already initialized."
    
    # Récupérer le token root et le sauvegarder dans un fichier sécurisé
    rootToken=$(grep "Initial Root Token: " generated_keys.txt | cut -c21-)
    echo $rootToken > root_token.txt
    chmod 600 root_token.txt
    # Exporter le token root et se connecter
    export VAULT_TOKEN=$rootToken

     # Vérifier que Vault est bien déverrouillé (unsealed)
    if [ "$(vault status | grep "Sealed" | awk '{print $2}')" == "true" ]; then
        echo "2- Vault est scellé."
        vault operator unseal $keyArray
    else
        echo "2- Vault est dégelé. Tout est prêt!"
    fi
    # Unseal Vault (si ce n'est pas encore fait)
    vault login $rootToken
fi

# Activer le moteur de secrets KV v2
vault secrets enable -path=kv-v2 kv-v2

# Créer une politique d'authentification
cat <<EOF > auth-policy.hcl
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "kv-v2/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Appliquer la politique
vault policy write admin auth-policy.hcl

# Créer un token d'administration basé sur la politique
vault token create -policy="admin" -field=token > admin-token.txt

# Assurez-vous que le fichier du token admin est sécurisé
chmod 600 admin-token.txt

echo "Token admin généré :"
cat admin-token.txt

# Ajouter une valeur de test à "my-secret-lambo"
vault kv put kv-v2/my-secret-lambo my-value=toto

# Vérifier que la valeur a bien été ajoutée et stockée dans consul
vault kv get kv-v2/my-secret-lambo
