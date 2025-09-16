log_level  = "DEBUG"
datacenter = "dc1"
region     = "nomad"
name       = "server.global"

data_dir  = "/opt/nomad/server"
bind_addr = "127.0.0.1"

advertise {
  http = "127.0.0.1:4646"
  rpc  = "127.0.0.1:4647"
  serf = "127.0.0.1:4648"
}

server {
  enabled          = true
  bootstrap_expect = 1
  server_join {
    retry_join     = ["127.0.0.1"]
    retry_max      = 0
    retry_interval = "15s"
  }
}

tls {
  http                   = true
  rpc                    = true
  ca_file                = "/etc/ssl/infra-certificates/vault-ca.crt"
  cert_file              = "/etc/ssl/infra-certificates/backend.crt"
  key_file               = "/etc/ssl/infra-certificates/backend.key"
  verify_server_hostname = false
  verify_https_client    = true
}
