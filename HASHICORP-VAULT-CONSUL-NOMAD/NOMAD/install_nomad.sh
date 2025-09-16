#!/bin/bash
set -e

# ========================
# Variables globales
# ========================
NOMAD_VERSION="1.10.4"
AUTOSCALER_VERSION="0.4.1"

NOMAD_BIN="/usr/local/bin/nomad"
AUTOSCALER_BIN="/usr/local/bin/nomad-autoscaler"

NOMAD_CONFIG_DIR="/etc/nomad.d"
AUTOSCALER_CONFIG_DIR="/etc/nomad-autoscaler.d"

NOMAD_LOG_DIR="/var/log/nomad"
NOMAD_LOG_FILE="$NOMAD_LOG_DIR/nomad.log"

NOMAD_USER="nomad_sa"
SSL_CERTIFICATE_PATH="/etc/ssl/infra-certificates"

echo "=== Installation interactive de Nomad + Autoscaler sur Ubuntu 24.04 ==="

# ========================
# Installation Nomad
# ========================
install_nomad() {
    NOMAD_ZIP="nomad_${NOMAD_VERSION}_linux_amd64.zip"
    NOMAD_URL="https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}"

    read -p "[1/6] Télécharger et installer Nomad version $NOMAD_VERSION ? (y/n) " do_install
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

# ========================
# Création des dossiers
# ========================
setup_dirs() {
    read -p "[2/6] Créer les dossiers de config et logs ? (y/n) " do_dirs
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

# ========================
# Création utilisateur systemd
# ========================
create_user() {
    read -p "[3/6] Créer l'utilisateur de service $NOMAD_USER ? (y/n) " do_user
    if [[ "$do_user" == "y" ]]; then
        if ! id -u "$NOMAD_USER" >/dev/null 2>&1; then
            useradd --system --no-create-home --shell /usr/sbin/nologin "$NOMAD_USER"
            usermod -aG docker "$NOMAD_USER"
            usermod -aG ssl-certs "$NOMAD_USER"
            echo "✅ Utilisateur $NOMAD_USER créé."
        else
            echo "⏩ L'utilisateur $NOMAD_USER existe déjà."
        fi
    else
        echo "⏩ Création de l'utilisateur ignorée."
    fi
}

# ========================
# Service systemd Nomad
# ========================
activated_nomad() {
    read -p "[4/6] Créer et démarrer le service systemd Nomad ? (y/n) " do_service
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

# ========================
# Installation Autoscaler
# ========================
install_autoscaler() {
    AUTOSCALER_ZIP="nomad-autoscaler_${AUTOSCALER_VERSION}_linux_amd64.zip"
    AUTOSCALER_URL="https://releases.hashicorp.com/nomad-autoscaler/${AUTOSCALER_VERSION}/${AUTOSCALER_ZIP}"

    read -p "[5/6] Installer Nomad Autoscaler version $AUTOSCALER_VERSION ? (y/n) " do_autoscaler
    if [[ "$do_autoscaler" == "y" ]]; then
        if ! command -v nomad-autoscaler >/dev/null 2>&1; then
            echo "Téléchargement de Nomad Autoscaler..."
            wget -q "$AUTOSCALER_URL" -O "/tmp/$AUTOSCALER_ZIP"
            unzip -o "/tmp/$AUTOSCALER_ZIP" -d /usr/local/bin/
            rm "/tmp/$AUTOSCALER_ZIP"
            chmod +x "$AUTOSCALER_BIN"
            echo "✅ Nomad Autoscaler installé."
        else
            echo "⏩ Nomad Autoscaler est déjà installé."
        fi
    else
        echo "⏩ Installation Nomad Autoscaler ignorée."
    fi
}

# ========================
# Config Autoscaler
# ========================
setup_autoscaler_config() {
    read -p "[6/6] Créer la config et service systemd pour Autoscaler ? (y/n) " do_autoscaler_cfg
    if [[ "$do_autoscaler_cfg" == "y" ]]; then
        mkdir -p "$AUTOSCALER_CONFIG_DIR"

        cat > $AUTOSCALER_CONFIG_DIR/nomad-autoscaler.hcl <<EOF
plugin_dir = "/opt/nomad-autoscaler/plugins"

nomad {
  address = "http://127.0.0.1:4646"
}

apm "nomad" {
  driver = "nomad-apm"
}

scaling "default" {
  enabled = true
  policy_eval_interval = "10s"
}
EOF

        cat > /etc/systemd/system/nomad-autoscaler.service <<EOF
[Unit]
Description=Nomad Autoscaler
After=network-online.target
Wants=network-online.target

[Service]
User=$NOMAD_USER
Group=$NOMAD_USER
ExecStart=$AUTOSCALER_BIN agent -config=$AUTOSCALER_CONFIG_DIR
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload
        systemctl enable nomad-autoscaler
        systemctl start nomad-autoscaler
        systemctl status nomad-autoscaler --no-pager
        echo "✅ Service Nomad Autoscaler activé."
    else
        echo "⏩ Config Autoscaler ignorée."
    fi
}

# ========================
# MAIN
# ========================
main() {
    install_nomad
    create_user
    setup_dirs
    activated_nomad
    install_autoscaler
    setup_autoscaler_config

    echo "=== Vérification connexion à Nomad ==="
    curl -s --cert $SSL_CERTIFICATE_PATH/backend.crt \
         --key $SSL_CERTIFICATE_PATH/backend.key \
         --cacert $SSL_CERTIFICATE_PATH/vault-ca.crt \
         https://127.0.0.1:4646/v1/status/leader | jq
}

main
