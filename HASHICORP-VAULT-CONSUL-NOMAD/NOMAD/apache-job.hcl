job "apache" {
  datacenters = ["dc1"]

  meta {
    foo = "bar"
  }

  group "web" {
    count = 3  # Vous souhaitez exécuter 3 réplicas

    network {
      port "http" {
        to = 80  # Port interne du conteneur (port utilisé à l'intérieur du conteneur)
      }
    }

    service {
      provider = "nomad"
      name     = "apache-web"
      port     = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "apache" {
      driver = "docker"

      config {
        image = "httpd:2.4"
        ports = ["http"]  # Liez le port "http" dynamiquement
        volumes = [
          "/opt/nomad/apache-html:/usr/local/apache2/htdocs:ro"  # Le volume pour le contenu Apache
        ]
      }

      resources {
        cpu    = 20  # 500 MHz de CPU par réplique
        memory = 66  # 256 MB de mémoire par réplique
      }

      template {
        data = <<-EOF
          <h1>Hello, Apache on Nomad!</h1>
          <ul>
            <li>Task: {{env "NOMAD_TASK_NAME"}}</li>
            <li>Group: {{env "NOMAD_GROUP_NAME"}}</li>
            <li>Job: {{env "NOMAD_JOB_NAME"}}</li>
            <li>Metadata value for foo: {{env "NOMAD_META_foo"}}</li>
            <li>Currently running on port: {{env "NOMAD_PORT_http"}}</li>
          </ul>
        EOF
        destination = "/opt/nomad/apache-html/index.html"  # Destination du fichier généré
      }
    }
  }
}

