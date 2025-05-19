# Configuration générale du serveur Vault
ui = true
disable_mlock = true
cluster_addr = "https://vault.infra.docker:8201"
api_addr = "https://vault.infra.docker:8200"

# Serveur Vault
listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_cert_file = "/opt/vault/tls/backend.crt"
  tls_key_file  = "/opt/vault/tls/backend.key"
  tls_client_ca_file = "/opt/vault/tls/vault-ca.crt"
}

# Backend de stockage Vault (Consul)
storage "consul" {
  address = "consul.infra.docker:8501"
  scheme  = "https"
  path    = "vault/data"
  node_id = "consul-node"
  tls_ca_file   = "/opt/vault/tls/vault-ca.crt"
  tls_cert_file = "/opt/vault/tls/backend.crt"
  tls_key_file  = "/opt/vault/tls/backend.key"
}

# Logs
log_level = "INFO"

# Méthode d'authentification (à modifier pour un environnement de production)
auth "approle" {
  path = "auth/approle/login"
}

# Sécurisation des tokens
default_lease_ttl = "168h"
max_lease_ttl = "720h"

# Metriques
# C'est un service à part chargé de gérer les métriques on va use prométheus ici
#telemetry {
#   statsite_address = "172.26.0.6:8125" 
#   disable_hostname = true
# }

