job "rp-apache" {
  datacenters = ["dc1"]

  group "web_server" {
    count = 1

    network {
      port "http" {
        to = 80 # Port interne du conteneur
      }
    }
    restart {
      attempts = 0
      mode     = "fail"
      # interval = "0s"
      # delay    = "0s"
    }
    reschedule {
      attempts  = 0
      unlimited = false
    }

    service {
      provider = "nomad"
      name     = "server-web-apache"
      port     = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "rp-apache" {
      driver = "docker"

      config {
        image = "httpd:2.4"
        ports = ["http"]
        volumes = [
          "/opt/nomad/apache-html:/usr/local/apache2/htdocs:ro"
        ]
      }

      resources {
        cpu    = 250 # 500 MHz de CPU par réplique
        memory = 250 # 256 MB de mémoire par réplique
      }
    }

  }
}

