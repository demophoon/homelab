module "vm-beryllium" {
  source = "../../modules/proxmox_vm"
  resource = "module.vm-beryllium"

  proxmox_node_prefix = "proxmox"
  proxmox_node_name = "proxmox"
  proxmox_host = "192.168.1.4"
  is_server = "true"

  cpu = 12
  memory = 16384
  proxmox_ssh_user = var.proxmox_ssh_user
  proxmox_ssh_password = var.proxmox_ssh_password
  #template_name = "104"
  template_name = data.tfe_outputs.prod_home.values.beryllium_template_id

  tailscale_tailnet_name = var.tailscale_tailnet_name
}

