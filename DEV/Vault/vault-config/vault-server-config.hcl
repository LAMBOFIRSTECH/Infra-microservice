# Configuration générale du serveur Vault
ui = true  # Active l'interface web de Vault

# Serveur Vault
listener "tcp" {
  address = "0.0.0.0:8200"  # Permet à Vault d'écouter sur toutes les interfaces réseau
  cluster_address = "0.0.0.0:8201"
  tls_disable = 1  # Désactive TLS (à activer en production)
}

# Backend de stockage Vault (Consul)
storage "consul" {
  address = "CONSUL-VAULT-STORAGE:8500"
  scheme  = "http"
  path    = "vault/"
}

# Logs
log_level = "INFO"

# Méthode d'authentification (à modifier pour un environnement de production)
auth "approle" {
  path = "auth/approle/login"
}

disable_mlock = false

# Sécurisation des tokens
default_lease_ttl = "168h"  # Durée par défaut des tokens (7 jours)
max_lease_ttl = "720h"      # Durée maximale des tokens
