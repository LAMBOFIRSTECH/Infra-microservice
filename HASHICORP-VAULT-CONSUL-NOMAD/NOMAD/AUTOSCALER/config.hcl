nomad {
  address = "http://127.0.0.1:4646"
}

apm "nomad" {
  driver = "nomad"
}

strategy "threshold" {
  driver = "threshold"
}

policy {
  check "memory-threshold" {
    source = "nomad-apm"
    query  = "memory"

    strategy "threshold" {
      upper_bound = 100
      lower_bound = 50
      delta       = 1
    }

    scaling "job" {
      target = "rp-apache"
      group  = "web_server"
    }
  }
}
