provider "google" {
  project     = "crypto-galaxy-246113"
  region      = "us-central1"
}

locals {
  rrdatas = local.has_load_balancer ? [digitalocean_loadbalancer.public[0].ip] : [for vm in module.vm-do : vm.ip]
}

removed {
  from = google_dns_record_set.main

  lifecycle {
    destroy = false
  }
}

removed {
  from = google_dns_record_set.compute-lb

  lifecycle {
    destroy = false
  }
}

removed {
  from = google_dns_record_set.flawedfauna

  lifecycle {
    destroy = false
  }
}
