#!/bin/sh
set -e

echo "[INFO] Vérification du répertoire slapd.d..."
if [ ! -d "$SLAPD_DATA_DIR/cn=config" ]; then
    echo "[INFO] Initialisation de la configuration OpenLDAP depuis init.ldif..."
    mkdir -p "$SLAPD_DATA_DIR"
    chown -R ldap:ldap "$SLAPD_DATA_DIR"
    slapadd -F "$SLAPD_DATA_DIR" -n 0 -l "$SLAPD_CONF_FILE" -v
fi

echo "[INFO] Vérification des permissions..."
mkdir -p /var/run/slapd /var/lib/ldap /var/log
chown -R ldap:ldap /var/run/slapd /var/lib/ldap /usr/local/etc/openldap /var/log
chmod -R 755 /var/run/slapd /var/lib/ldap

echo "[INFO] Création des sockets LDAPI..."
mkdir -p /var/run/openldap
chown ldap:ldap /var/run/openldap

# Démarrer slapd avant la vérification de l'utilisateur
echo "[INFO] Lancement de slapd..."
exec gosu ldap /usr/local/libexec/slapd \
  -F "$SLAPD_DATA_DIR" \
  -h "ldap://0.0.0.0 ldaps://0.0.0.0 ldapi://%2Fvar%2Frun%2Fopenldap%2Fldapi" \
  -u ldap \
  -g ldap \
  -d stats &
  
# Vérification de l'existence du DN admin
echo "[INFO] Vérification de l'existence de l'utilisateur 'cn=admin,dc=lamboft,dc=it'..."

# Attendre un peu que le serveur slapd démarre (environ 5 secondes)
sleep 5

# Vérification de l'existence de l'utilisateur
ldapsearch -x -D "cn=admin,dc=lamboft,dc=it" -w "\!\!Art94721805\&" -b "dc=lamboft,dc=it" "(cn=admin)" || {
    echo "[INFO] Utilisateur 'cn=admin,dc=lamboft,dc=it' introuvable. Création de l'utilisateur..."
    # Si l'utilisateur n'existe pas, ajout du fichier LDIF pour créer l'utilisateur
    ldapadd -x -D "cn=admin,dc=lamboft,dc=it" -w "\!\!Art94721805\&" -f /usr/local/etc/openldap/init.ldif
}


