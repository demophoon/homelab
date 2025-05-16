provider "google" {
  project     = "crypto-galaxy-246113"
  region      = "us-central1"
}

resource "google_dns_record_set" "main" {
  name         = "brittg.com."
  type         = "A"
  ttl          = 300
  managed_zone = data.tfe_outputs.prod_home.values.google_dns_managed_zone_brittg_com

  rrdatas = [digitalocean_loadbalancer.public.ip]
  #rrdatas = [ for vm in module.vm-do : vm.ip ]
}

resource "google_dns_record_set" "compute-lb" {
  name         = "compute-lb.demophoon.com."
  type         = "A"
  ttl          = 300
  managed_zone = data.tfe_outputs.prod_home.values.google_dns_managed_zone_demophoon_com

  rrdatas = [digitalocean_loadbalancer.public.ip]
  #rrdatas = [ for vm in module.vm-do : vm.ip ]
}

