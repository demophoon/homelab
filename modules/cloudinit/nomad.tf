resource "vault_token" "nomad_token" {
  policies = ["nomad-server"]
  period = "2160h"
  no_parent = true
}

data "template_file" "nomad_config" {
  template = file("${path.module}/templates/nomad.hcl")
  vars = {
    region      = var.nomad_region
    provider    = var.nomad_provider
    is_server   = var.server
    include_mounts = var.nomad_region == "cascadia" ? true : false
    include_keepalived = var.nomad_region == "cascadia" ? true : false
  }
}

