resource "null_resource" "created_at" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

resource "random_pet" "server_name" {
  length = 1
  prefix = "do"

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
}


resource "digitalocean_droplet" "web" {
  name      = random_pet.server_name.id
  image     = "ubuntu-22-04-x64"
  region    = "sfo3"
  size      = var.size
  #size      = "s-2vcpu-4gb-amd"
  #size      = "s-1vcpu-1gb-amd"
  #size      = "s-1vcpu-1gb-intel"
  user_data = module.ci-data.config

  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      null_resource.created_at,
    ]
  }
}
