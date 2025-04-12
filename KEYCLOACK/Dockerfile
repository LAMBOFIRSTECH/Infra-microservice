FROM lamboft/postgres:17-no-vuln-alpine3.21

# # Installer cron
# RUN apk update && apk add cron && rm -rf /var/lib/apk/lists/*

# # Copier les scripts dans l'image
# COPY backup.sh /backup.sh
# COPY crontab.txt /etc/cron.d/db-backup

# # Donner les droits d'exécution
# RUN chmod +x /backup.sh

# # Appliquer la crontab et donner les bons droits
# RUN crontab /etc/cron.d/db-backup
# RUN chmod 0644 /etc/cron.d/db-backup

# # Lancer postgres ET cron
# CMD cron && docker-entrypoint.sh postgres