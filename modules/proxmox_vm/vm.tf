resource "random_pet" "server_name" {
  length = 1
  prefix = var.proxmox_node_prefix
}

module "ci-data" {
  source = "../cloudinit"

  hostname = random_pet.server_name.id
  nomad_region = "cascadia"
  nomad_provider = "virtual"
  server = var.is_server
  resource = var.resource
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node_name

  source_raw {
    data = module.ci-data.config
    file_name = "${random_pet.server_name.id}.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  lifecycle {
    ignore_changes = [
      id,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      vm_id,
      cpu,
      initialization,
      network_device,
    ]
  }

  provisioner "local-exec" {
    when = destroy
    command = "./cleanup.sh ${self.name}"
    working_dir = path.module
  }

  name        = random_pet.server_name.id
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name = var.proxmox_node_name

  agent {
    enabled = true
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  disk {
    interface = "virtio0"
    file_format = "qcow2"
    file_id = var.template_name
    size = 64
  }

  #clone {
  #  datastore_id = "local-lvm"
  #  vm_id = var.template_name
  #}

  cpu {
    cores = var.cpu
    type = "host"
  }

  memory {
    dedicated = var.memory
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
