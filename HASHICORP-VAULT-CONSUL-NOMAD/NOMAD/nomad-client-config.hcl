client {
  enabled           = true
  network_interface = "eth0"
}

tls {
  rpc       = true
  ca_file   = "/etc/ssl/infra-certificates/vault-ca.crt"
  cert_file = "/etc/ssl/infra-certificates/backend.crt"
  key_file  = "/etc/ssl/infra-certificates/backend.key"
  # verify_server_hostname = true
  verify_https_client = true
}

plugin "docker" {
  config {
    endpoint     = "unix:///var/run/docker.sock"
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
