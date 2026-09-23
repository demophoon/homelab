resource "null_resource" "created_at" {
  triggers = {
    timestamp = var.created_at != null ? var.created_at : timestamp()
  }
}

resource "random_pet" "server_name" {
  length = 1
  prefix = "vultr"

  keepers = {
    created_at = null_resource.created_at.id
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.created_at,
    ]
  }
}

module "ci-data" {
  source = "../cloudinit"

  hostname              = random_pet.server_name.id
  nomad_region          = "vultr"
  nomad_provider        = "virtual"
  node_pool             = "ingress"
  server                = var.is_server
  workspace             = var.workspace
  resource              = var.resource
  backplane_certificate = var.backplane_certificate

  register_reprovision = var.register_reprovision
  reprovision_dow      = var.reprovision_dow

  pv_name = var.workspace
}

resource "vultr_instance" "web" {
  plan      = var.size
  region    = var.region
  os_id     = var.os_id
  hostname  = random_pet.server_name.id
  user_data = module.ci-data.config

  lifecycle {
    replace_triggered_by = [
      null_resource.created_at,
    ]
  }
}

resource "vultr_block_storage" "data_disk" {
  count = var.persistant_disk > 0 ? 1 : 0

  label                = "${var.workspace}-data"
  region               = var.region
  size_gb              = var.persistant_disk
  attached_to_instance = vultr_instance.web.id
  live                 = true
}
