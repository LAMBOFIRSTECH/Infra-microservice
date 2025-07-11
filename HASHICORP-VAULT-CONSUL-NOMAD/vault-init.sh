#!/bin/bash
colors() {
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    CYAN="\033[1;36m"
    NC="\033[0m" # Réinitialisation
    printf "${!1}${2} ${NC}\n"
}

export VAULT_ADDR=$VAULT_ADDR # L'adresse de Vault à utiliser dans les scripts .hcl
export VAULT_CACERT="/opt/vault/tls/vault-ca.crt"

# Vérifier si Vault est initialisé
INITIALIZED=$(vault status | grep "Initialized" | awk '{print $2}')
if [ "$INITIALIZED" != "true" ]; then
    echo -e "${YELLOW}Vault is not initialized. Initializing Vault... ${NC}"
    # Initialiser Vault avec 3 clés d'unsealing et un seuil de 2
    vault operator init -key-shares=3 -key-threshold=2 >/vault/generated_keys.txt

    # Extraire les clés d'unsealing
    keyArray=$(grep "Unseal Key " /vault/generated_keys.txt | cut -c15-)
    rootToken=$(grep "Initial Root Token: " /vault/generated_keys.txt | cut -c21-)

    # Sauvegarder le token root dans un fichier sécurisé
    echo $rootToken >token.txt
    chmod 600 token.txt

    # Sauvegarder les clés d'unsealing dans un fichier sécurisé
    for key in $keyArray; do
        echo $key
    done
    # Exporter le token root pour l'utiliser
    export VAULT_TOKEN=$rootToken

    # Déverrouiller Vault
    for key in $keyArray; do
        vault operator unseal $key
        if [ $? -ne 0 ]; then
            echo "Erreur lors du unseal avec la clé : $key"
            exit 1
        fi
    done

    # Vérifier que Vault est bien déverrouillé (unsealed)
    if [ "$(vault status | grep "Sealed" | awk '{print $2}')" == "true" ]; then
        echo -e "${CYAN}1- Vault est scellé. Veuillez vérifier les unseal Keys. ${NC}"
        exit 1
    else
        echo -e "${CYAN}1- Vault est dégelé. Tout est prêt! ✅ ${NC}"

    fi
else
    echo -e "${YELLOW}Vault is already initialized. ${NC}"
    # Récupérer le token root et le sauvegarder dans un fichier sécurisé

    rootToken=$(grep "Initial Root Token: " generated_keys.txt | cut -c21-)
    echo $rootToken >token.txt
    chmod 600 token.txt
    # Exporter le token root et se connecter
    export VAULT_TOKEN=$rootToken

    # Déverrouiller Vault si nécessaire
    if [ "$(vault status | grep "Sealed" | awk '{print $2}')" == "true" ]; then
        echo -e "${GREEN}2- Vault est scellé. Déverrouillage en cours... 🚫 ${NC}"
        # Déverrouiller avec les clés d'unsealing
        vault operator unseal $keyArray
    else
        echo -e "${GREEN} ✅ 2- Vault est déjà dégelé.${NC}"
    fi
fi
exit 0
