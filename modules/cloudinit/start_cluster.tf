module "approle" {
  source = "./approle"
  hostname = var.hostname
}

resource "vault_kv_secret_v2" "example" {
  mount                      = "kv"
  name                       = "infra/${var.hostname}/nomad_server"
  data_json                  = jsonencode(
    {
      token = vault_token.nomad_token.client_token,
    }
  )
}

locals {
  start_cluster_sh = templatefile(
    "${path.module}/templates/start_cluster.sh",
    {
      include_media = var.nomad_region == "cascadia" ? true : false
      is_server   = var.server
      hostname      = var.hostname
      role_id       = module.approle.provision_role_id
      secret_id     = module.approle.secret_id
    }
  )
}
