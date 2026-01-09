module "vm-auxiliary-1" {
  source = "../../modules/proxmox_vm"
  resource = "module.vm-auxiliary-1"

  proxmox_node_prefix = "proxmox-aux-1"
  proxmox_node_name = "proxmox"
  proxmox_host = "192.168.1.4"
  is_server = "true"

  cpu = 12
  memory = 32768
  proxmox_ssh_user = var.proxmox_ssh_user
  proxmox_ssh_password = var.proxmox_ssh_password
  #template_name = "104"
  template_name = data.tfe_outputs.prod_home.values.beryllium_template_id

  tailscale_tailnet_name = var.tailscale_tailnet_name
  workspace = "proxmox-aux"
  backplane_certificate = data.tfe_outputs.prod_home.values.backplane_certificate

  register_reprovision = true
  reprovision_dow = 1
}
