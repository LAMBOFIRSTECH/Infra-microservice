#!/bin/bash
set -e

# Variables
ENVOY_SIGNING_KEY_URL="https://apt.envoyproxy.io/signing.key"
ENVOY_KEYRINGS_PATH="/etc/apt/keyrings/envoy-keyring.gpg"
ENVOY_CONFIG_DIR="/etc/envoy"
ENVOY_CONFIG_FILE="$ENVOY_CONFIG_DIR/envoy.yaml"
ENVOY_LOG_DIR="/var/log/envoy"
ENVOY_LOG_FILE="$ENVOY_LOG_DIR/envoy.log"
ENVOY_USER="envoy_sa"

echo "=== Installation interactive de Envoy Proxy sur Ubuntu 24.04 ==="

installed() {
    mkdir -p /etc/apt/keyrings

    echo "[1/4] Téléchargement de la clé GPG d'Envoy"
    if [ -f "$ENVOY_KEYRINGS_PATH" ]; then
        read -p "⚠️ Le fichier $ENVOY_KEYRINGS_PATH existe déjà. L'écraser ? (y/n) " overwrite
        if [[ "$overwrite" == "y" ]]; then
            wget -qO- "$ENVOY_SIGNING_KEY_URL" | gpg --dearmor -o "$ENVOY_KEYRINGS_PATH"
            echo "✅ Clé remplacée."
        else
            echo "⏩ Clé conservée."
        fi
    else
        wget -qO- "$ENVOY_SIGNING_KEY_URL" | gpg --dearmor -o "$ENVOY_KEYRINGS_PATH"
        echo "✅ Clé installée."
    fi

    echo "[2/4] Configuration du dépôt Envoy"
    if [ -f /etc/apt/sources.list.d/envoy.list ]; then
        read -p "⚠️ Le fichier /etc/apt/sources.list.d/envoy.list existe déjà. Le recréer ? (y/n) " recreate
        if [[ "$recreate" == "y" ]]; then
            echo "deb [arch=$(dpkg --print-architecture) signed-by=$ENVOY_KEYRINGS_PATH] https://apt.envoyproxy.io jammy main" > /etc/apt/sources.list.d/envoy.list
            echo "✅ Dépôt recréé."
        else
            echo "⏩ Dépôt conservé."
        fi
    else
        echo "deb [arch=$(dpkg --print-architecture) signed-by=$ENVOY_KEYRINGS_PATH] https://apt.envoyproxy.io jammy main" > /etc/apt/sources.list.d/envoy.list
        echo "✅ Dépôt ajouté."
    fi

    read -p "[3/4] Lancer 'apt update' maintenant ? (y/n) " do_update
    if [[ "$do_update" == "y" ]]; then
        apt update
    else
        echo "⏩ Étape apt update ignorée."
    fi

    read -p "[4/4] Installer Envoy maintenant ? (y/n) " do_install
    if [[ "$do_install" == "y" ]]; then
        apt install -y envoy
        echo "✅ Envoy installé."
        envoy --version
    else
        echo "⏩ Installation ignorée."
    fi

    # Création du compte service idempotent
    if ! id -u "$ENVOY_USER" >/dev/null 2>&1; then
        echo "Création du compte de service $ENVOY_USER"
        useradd --system --no-create-home --shell /usr/sbin/nologin "$ENVOY_USER"
    else
        echo "⏩ L'utilisateur $ENVOY_USER existe déjà."
    fi

    # Création du dossier et fichier de logs
    mkdir -p "$ENVOY_LOG_DIR"
    touch "$ENVOY_LOG_FILE"
    chmod 644 "$ENVOY_LOG_FILE"
}

activated_envoy() {
    echo "Création du service systemd pour Envoy"
    cat > /etc/systemd/system/envoy.service <<EOF
[Unit]
Description=Envoy proxy pour les services orchestrés par Nomad
After=network-online.target
Wants=network-online.target

[Service]
User=$ENVOY_USER
Group=$ENVOY_USER
ExecStart=/usr/bin/envoy -c $ENVOY_CONFIG_FILE
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536
StandardOutput=append:$ENVOY_LOG_FILE
StandardError=append:$ENVOY_LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable envoy
    systemctl start envoy
    systemctl status envoy
}

main() {
    installed
    activated_envoy
}

main
