pid_file = "./pidfile"
auto_auth {
  method {
    type="approle" 
    config = {
      role_id_file_path   = "/vault/data/role-id-file"  # Chemin vers le fichier contenant le role_id
      secret_id_file_path = "/vault/data/secret-id-file"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "/tmp/token" # C'est ici que le Token de approle sera stocké
    }
  }
}

vault {
  address = "http://172.19.0.6:8200"
}