pid_file = "./pidfile"
auto_auth {
  method {
    type="approle" 
    config = {
      role_id_file_path   = "/vault/data/role-id-file"
      secret_id_file_path = "/vault/data/secret-id-file"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "/tmp/token"
    }
  }
}

vault {
  address = "https://vault.infra.docker:8200"
}