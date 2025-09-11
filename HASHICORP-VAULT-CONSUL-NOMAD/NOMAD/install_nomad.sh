#!/bin/bash
set -e

# Variables
NOMAD_VERSION="1.10.4"
NOMAD_BIN="/usr/local/bin/nomad"
NOMAD_CONFIG_DIR="/etc/nomad.d"
NOMAD_LOG_DIR="/var/log/nomad"
NOMAD_LOG_FILE="$NOMAD_LOG_DIR/nomad.log"
NOMAD_USER="nomad_sa"
SSL_CERTIFICATE_PATH="/etc/ssl/infra-certificates"

echo "=== Installation interactive de Nomad sur Ubuntu 24.04 ==="

install_nomad() {
    NOMAD_ZIP="nomad_${NOMAD_VERSION}_linux_amd64.zip"
    NOMAD_URL="https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}"

    read -p "[1/4] Télécharger et installer Nomad version $NOMAD_VERSION ? (y/n) " do_install
    if [[ "$do_install" == "y" ]]; then
        if ! command -v nomad >/dev/null 2>&1; then
            echo "Téléchargement de Nomad..."
            wget -q "$NOMAD_URL" -O "/tmp/$NOMAD_ZIP"

            echo "Installation de Nomad..."
            unzip -o "/tmp/$NOMAD_ZIP" -d /usr/local/bin/
            rm "/tmp/$NOMAD_ZIP"
            chmod +x "$NOMAD_BIN"
            echo "✅ Nomad installé."
        else
            echo "⏩ Nomad est déjà installé."
        fi

        nomad version || { echo "❌ Erreur lors de la vérification de Nomad"; exit 1; }
    else
        echo "⏩ Installation Nomad ignorée."
    fi
}

setup_dirs() {
    read -p "[2/4] Créer les dossiers de config et logs ? (y/n) " do_dirs
    if [[ "$do_dirs" == "y" ]]; then
        mkdir -p "$NOMAD_CONFIG_DIR" "$NOMAD_LOG_DIR" /opt/nomad /opt/alloc_mounts
        chmod 750 /opt/alloc_mounts
        touch "$NOMAD_LOG_FILE"
        chmod 640 "$NOMAD_LOG_FILE"
        echo "✅ Dossiers créés."

        # Copier les fichiers de config si présents
        [ -f ./nomad-client-config.hcl ] && cp ./nomad-client-config.hcl "$NOMAD_CONFIG_DIR/"
        [ -f ./nomad-server-config.hcl ] && cp ./nomad-server-config.hcl "$NOMAD_CONFIG_DIR/"
        chown -R "$NOMAD_USER:$NOMAD_USER" "$NOMAD_CONFIG_DIR" "$NOMAD_LOG_DIR" /opt/nomad
    else
        echo "⏩ Création des dossiers ignorée."
    fi
}

create_user() {
    read -p "[3/4] Créer l'utilisateur de service $NOMAD_USER ? (y/n) " do_user
    if [[ "$do_user" == "y" ]]; then
        if ! id -u "$NOMAD_USER" >/dev/null 2>&1; then
            useradd --system --no-create-home --shell /usr/sbin/nologin "$NOMAD_USER"
            usermod -aG docker "$NOMAD_USER"
            usermod -aG ssl-certs NOMAD_USER
            echo "✅ Utilisateur $NOMAD_USER créé."
        else
            echo "⏩ L'utilisateur $NOMAD_USER existe déjà."
        fi
    else
        echo "⏩ Création de l'utilisateur ignorée."
    fi
}

activated_nomad() {
    read -p "[4/4] Créer et démarrer le service systemd Nomad ? (y/n) " do_service
    if [[ "$do_service" == "y" ]]; then
        cat > /etc/systemd/system/nomad.service <<EOF
[Unit]
Description=Nomad Orchestrateur pour les API microservices
After=network-online.target
Wants=network-online.target

[Service]
User=$NOMAD_USER
Group=$NOMAD_USER
ExecStart=$NOMAD_BIN agent -config=$NOMAD_CONFIG_DIR/nomad-server-config.hcl -config=$NOMAD_CONFIG_DIR/nomad-client-config.hcl
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536
StandardOutput=append:$NOMAD_LOG_FILE
StandardError=append:$NOMAD_LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload
        systemctl enable nomad
        systemctl start nomad
        systemctl status nomad --no-pager
        echo "✅ Service Nomad activé."
    else
        echo "⏩ Service systemd ignoré."
    fi
}

main() {
    install_nomad
    create_user
    setup_dirs
    activated_nomad
    curl -s --cert $SSL_CERTIFICATE_PATH/backend.crt --key $SSL_CERTIFICATE_PATH/backend.key  --cacert $SSL_CERTIFICATE_PATH/vault-ca.crt https://127.0.0.1:4646/v1/status/leader | jq
    # Cette commande ci-dessus doit retourner l'ip du serveur + le port API de nomad
}

main

