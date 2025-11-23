module "vm-sol-aux" {
  source = "../../modules/proxmox_vm"
  resource = "module.vm-sol-aux"

  proxmox_node_prefix = "sol-aux"
  proxmox_node_name = "sol"
  proxmox_host = "192.168.1.220"
  is_server = "false"

  cpu = 2
  memory = 1024
  proxmox_ssh_user = var.proxmox_ssh_user
  proxmox_ssh_password = var.proxmox_ssh_password
  template_name = data.tfe_outputs.prod_home.values.sol_template_id

  tailscale_tailnet_name = var.tailscale_tailnet_name
  workspace = "sol-aux"
  backplane_certificate = data.tfe_outputs.prod_home.values.backplane_certificate
}
