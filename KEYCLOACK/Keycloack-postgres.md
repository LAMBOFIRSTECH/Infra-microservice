# Taches infrastructure à faire entre Keycloack et la bd Postgres
## Sécurisation de Keycloak et PostgreSQL

### 1. Activer SSL dans PostgreSQL
[X] Ajouter un certificat SSL à PostgreSQL pour sécuriser les communications.
[ ] Modifier la configuration de PostgreSQL pour activer SSL (`postgresql.conf`).

### 2. Créer un service dédié à Keycloak dans PostgreSQL
[ ] Créer un utilisateur spécifique pour Keycloak dans PostgreSQL.
[ ] Lui attribuer uniquement les permissions **Read, Update, Write (RUW)**, sans privilèges administratifs.

### 3. Utiliser un mot de passe fort pour l’accès à la base de données
[ ] Générer un mot de passe sécurisé avec un outil comme OpenSSL
[ ] Configurer PostgreSQL pour exiger un mot de passe fort.

### 4. Planifier un changement de mot de passe périodique
[ ] Automatiser le changement du mot de passe de Keycloak à chaque tentative de connexion à PostgreSQL.
[ ] Mettre en place une politique de rotation des mots de passe. (Hashicorp Vault fera l'affaire)

### 5. Limiter les accès à la base de données PostgreSQL
[ ] Restreindre l’accès à PostgreSQL aux seules IP autorisées via le fichier `pg_hba.conf`.
[ ] Activer un pare-feu pour renforcer la sécurité réseau.

### 6. Chiffrer les données sensibles dans PostgreSQL
[ ] Identifier les données sensibles à chiffrer.
[ ] Utiliser **pgcrypto** pour le chiffrement des données sensibles.

### 7. Mettre en place des sauvegardes sécurisées
[ ] Définir une stratégie de sauvegarde de la base de données.
[ ] Stocker les sauvegardes dans un emplacement sécurisé.
[ ] Chiffrer les sauvegardes avant stockage.

### 8. Automatiser les mises à jour de sécurité
[ ] Mettre en place un gestionnaire de paquets pour assurer les mises à jour de sécurité.
[ ] Automatiser les mises à jour pour Keycloak et PostgreSQL.

### 9. Activer la journalisation
[ ] Activer et configurer la journalisation dans PostgreSQL (`postgresql.conf`).
[ ] Activer les logs pour Keycloak et PostgreSQL afin de suivre les connexions et les événements.

### 10. Surveillance avec Prometheus et Grafana
[ ] Utiliser **Prometheus** pour collecter les métriques de Keycloak et PostgreSQL.
[ ] Configurer **Grafana** pour visualiser ces métriques.
[ ] Mettre en place des alertes pour les échecs de connexion entre Keycloak et PostgreSQL.
