resource "vault_pki_secret_backend_cert" "consul_internal" {
  backend = "pki"
  name = "backplane"
  alt_names = [var.hostname, "${var.hostname}.dc1.consul.demophoon.com"]
  common_name = "consul.service.consul.demophoon.com"
}

locals {
  consul_config = templatefile(
    "${path.module}/templates/consul.hcl",
    {
      is_server        = var.server
      include_services = var.nomad_region == "cascadia" ? true : false
      resource         = var.resource
    }
  )
}
