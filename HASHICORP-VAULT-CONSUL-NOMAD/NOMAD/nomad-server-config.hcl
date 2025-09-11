log_level = "DEBUG"
data_dir  = "/opt/nomad"
bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = 1 # 3 pour la prod

}
tls {
  http            = true
  rpc             = true
  ca_file         = "/etc/ssl/infra-certificates/vault-ca.crt"
  cert_file       = "/etc/ssl/infra-certificates/backend.crt"
  key_file        = "/etc/ssl/infra-certificates/backend.key"
  # verify_server_hostname = true
  verify_https_client = true
}
