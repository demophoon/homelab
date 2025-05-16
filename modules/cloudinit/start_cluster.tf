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

data "template_file" "start_cluster_sh" {
  template = file("${path.module}/templates/start_cluster.sh")
  vars = {
    include_media = var.nomad_region == "cascadia" ? true : false
    hostname      = var.hostname
    role_id       = module.approle.provision_role_id
    secret_id     = module.approle.secret_id
  }
}
