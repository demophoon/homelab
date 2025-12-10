module "approle" {
  source = "./approle"
  hostname = var.hostname
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
      pv_name       = var.pv_name

      use_miren = var.use_miren
    }
  )
}
