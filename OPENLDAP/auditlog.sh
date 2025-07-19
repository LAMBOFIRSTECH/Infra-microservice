#!/bin/sh

echo "MISE A JOUR DU MODULE AUDITLOG-----------------"
# --copy-service
chown root:root /tmp/auditlog.ldif
if [ $? -ne 0 ]; then
    echo "Le propriétaire n'a pas été modifié pour auditlog.ldif."
    exit 1
fi

chmod 644 /tmp/auditlog.ldif
if [ $? -ne 0 ]; then
    echo "Les droits n'ont pas été modifiés pour auditlog.ldif."
    exit 1
fi
chown openldap:openldap /var/log/ldap-audit.log
if [ $? -ne 0 ]; then
    echo "Le propriétaire openldap n'a pas bien été ajouté. Pour /var/log/ldap-audit.log"
    exit 1
fi
chmod 640 /var/log/ldap-audit.log
if [ $? -ne 0 ]; then
    echo "Les droits n'ont pas été modifiés dans var/log."
    exit 1
fi
echo "status du service slapd"
service slapd stop
service slapd start
if [ $? -ne 0 ]; then
    echo "Le service slapd n'est pas démarré."
    exit 1
fi
service slapd status
# Vérifie si le module auditlog est déjà présent
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/auditlog.ldif
# si la commande réussit on applique la commande suivante
ldapsearch -Y EXTERNAL -H ldapi:/// -b "cn=config" "(objectClass=olcOverlayConfig)"
installer inotify
installer watchdog
installer pika
nohup ./automate_ldap_log_output_txt.sh >master_script.log 2>&1 &
kill $(pgrep -f automate_ldap_log_output_txt.sh)

nohup ./monitoring_scripts.sh >general_logs.log 2>&1 &
kill $(pgrep -f monitoring_scripts.sh)
# On doit pouvoir voir l'overlay auditlog dans la liste des overlays
