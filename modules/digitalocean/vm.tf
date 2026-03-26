resource "null_resource" "created_at" {
  triggers = {
    timestamp = var.created_at != null ? var.created_at : timestamp()
  }
}

resource "random_pet" "server_name" {
  length = 1
  prefix = "do"

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
  resource = var.resource

  hostname = random_pet.server_name.id
  nomad_region = "digitalocean"
  nomad_provider = "virtual"
  node_pool = "ingress"
  server = var.is_server
  workspace = var.workspace
  backplane_certificate = var.backplane_certificate

  register_reprovision = var.register_reprovision
  reprovision_dow      = var.reprovision_dow

  pv_name = var.workspace
}


resource "digitalocean_droplet" "web" {
  name      = random_pet.server_name.id
  image     = "ubuntu-22-04-x64"
  region    = "sfo3"
  size      = var.size
  user_data = module.ci-data.config

  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      null_resource.created_at,
    ]
  }
}

resource "digitalocean_volume" "data_disk" {
  count             = var.persistant_disk > 0 ? 1 : 0

  name              = "${var.workspace}-data"
  region            = "sfo3"
  size              = var.persistant_disk

  initial_filesystem_type   = "ext4"
  initial_filesystem_label  = var.workspace
}

resource "digitalocean_volume_attachment" "data_disk_attach" {
  count = var.persistant_disk > 0 ? 1 : 0

  droplet_id = digitalocean_droplet.web.id
  volume_id  = digitalocean_volume.data_disk[0].id
}
