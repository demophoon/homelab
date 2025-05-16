resource "vault_pki_secret_backend_cert" "consul_internal" {
  backend = "pki"
  name = "backplane"
  alt_names = [var.hostname]
  common_name = "consul.service.consul.demophoon.com"
}

data "template_file" "consul_config" {
  template = file("${path.module}/templates/consul.hcl")
  vars = {
    is_server   = var.server
    include_services = var.nomad_region == "cascadia" ? true : false
    resource   = var.resource
  }
}

