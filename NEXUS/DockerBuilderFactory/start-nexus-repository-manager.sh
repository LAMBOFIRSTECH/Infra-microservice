#!/bin/sh

set -e  # Arrêter le script en cas d'erreur

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

KEYSTORE_DIR="/opt/sonatype/tls"
KEYSTORE_P12="${KEYSTORE_DIR}/keystore.p12"
KEYSTORE_JKS="/opt/sonatype/nexus/etc/ssl/keystore.jks"

# Supprimer l'ancien keystore s'il existe
[ -f "$KEYSTORE_JKS" ] && rm -f "$KEYSTORE_JKS"

# Génération du keystore PKCS12
colors "YELLOW" "⏳ Génération du certificat PKCS12"
openssl pkcs12 -export \
    -in /opt/sonatype/nexus/etc/ssl/backend.crt \
    -inkey /opt/sonatype/nexus/etc/ssl/backend.key \
    -out "$KEYSTORE_P12" \
    -name nexus \
    -CAfile /opt/sonatype/nexus/etc/ssl/vault-ca.crt \
    -caname infra_docker \
    -passout pass:changeit

colors "YELLOW" "⏳ Conversion en keystore JKS"
keytool -importkeystore \
    -srckeystore "$KEYSTORE_P12" \
    -srcstoretype PKCS12 \
    -srcstorepass changeit \
    -destkeystore "$KEYSTORE_JKS" \
    -deststorepass changeit \
    -destkeypass changeit \
    -alias nexus \
    -noprompt

colors "CYAN" "✅ Certificat JKS généré avec succès"
colors "GREEN" "🏁 Lancement de Nexus"

cd /opt/sonatype/nexus
exec ./bin/nexus run
