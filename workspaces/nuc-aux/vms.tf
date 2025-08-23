module "vm-nuc-2" {
  source = "../../modules/proxmox_vm"
  resource = "module.vm-nuc"

  proxmox_node_prefix = "nuc-aux-1"
  proxmox_node_name = "nuc"
  proxmox_host = "192.168.1.35"
  is_server = "true"

  cpu = 4
  memory = 14336
  proxmox_ssh_user = var.proxmox_ssh_user
  proxmox_ssh_password = var.proxmox_ssh_password
  template_name = data.tfe_outputs.prod_home.values.nuc_template_id

  tailscale_tailnet_name = var.tailscale_tailnet_name
  workspace = "nuc-aux"
}
