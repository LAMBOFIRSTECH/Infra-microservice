# Configuration TLS
tls {
  defaults {
    ca_file = "/opt/consul/tls/vault-ca.crt"  
    cert_file = "/opt/consul/tls/backend.crt" 
    key_file = "/opt/consul/tls/backend.key"    
    verify_incoming = true
    verify_outgoing = true
  }

  internal_rpc {
    verify_server_hostname = false
  }
}

# Configuration du serveur Consul
server = true
bootstrap_expect = 1
data_dir = "/consul/data"
node_name = "consul-node"
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "172.26.0.3"

# Ports HTTP et HTTPS
ports {
  http = 8500
  https = 8501
}

# UI
ui_config {
  enabled = true
}

log_level = "INFO"
