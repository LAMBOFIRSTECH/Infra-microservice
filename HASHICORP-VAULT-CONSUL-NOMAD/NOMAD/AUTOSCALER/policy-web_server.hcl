scaling "web_server_policy" {
  enabled = true
  min     = 1
  max     = 4

  policy {
    cooldown            = "30s"
    evaluation_interval = "10s"

    check "cpu_threshold" {
      source = "nomad"
      query  = "cpu_allocated_percentage"
      strategy "threshold" {
        target     = 10
        comparator = ">"
      }
    }

    check "mem_threshold" {
      source = "nomad"
      query  = "mem_allocated_percentage"
      strategy "threshold" {
        target     = 10
        comparator = ">"
      }
    }

    target "nomad-target" {
      Type       = "nomad"         # sensibilité à la casse
      Job        = "rp-apache"     # Job avec J majuscule
      Group      = "web_server"    # Group avec G majuscule
      NodeClass  = "hashistack"    # facultatif
    }

  }
}
