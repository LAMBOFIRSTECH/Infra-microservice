region     = "nomad"
datacenter = "dc1"
client {
  enabled           = true
  network_interface = "lo"
  servers           = ["127.0.0.1:4647"]
}

data_dir  = "/opt/nomad/client"
bind_addr = "127.0.0.1"

ports {
  http = 4649
  rpc  = 4650
  serf = 4651
}

advertise {
  http = "127.0.0.1:4649"
  rpc  = "127.0.0.1:4650"
  serf = "127.0.0.1:4651"
}

tls {
  rpc                    = true
  ca_file                = "/etc/ssl/infra-certificates/vault-ca.crt"
  cert_file              = "/etc/ssl/infra-certificates/client.crt"
  key_file               = "/etc/ssl/infra-certificates/client.key"
  verify_server_hostname = false
  verify_https_client    = true
}
plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"
    # cpu_cfs_quota = true # Pas présent pour la version community ## C'est grace à ceci qu'on dire à nomad de se limiter aux ressources qu'on a défini pour chaque job allocation
    extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
    gc {
      image       = true
      image_delay = "3m"
      container   = true
    }
    volumes {
      enabled      = true
      selinuxlabel = "z"
    }
    allow_privileged = false
    allow_caps       = ["chown", "net_raw"]
  }
}
