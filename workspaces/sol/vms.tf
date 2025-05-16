module "vm-sol" {
  source = "../../modules/proxmox_vm"
  resource = "module.vm-sol"

  proxmox_node_prefix = "sol"
  proxmox_node_name = "sol"
  proxmox_host = "192.168.1.220"
  is_server = "true"

  cpu = 2
  memory = 8192
  proxmox_ssh_user = var.proxmox_ssh_user
  proxmox_ssh_password = var.proxmox_ssh_password
  template_name = data.tfe_outputs.prod_home.values.sol_template_id

  tailscale_tailnet_name = var.tailscale_tailnet_name
}
