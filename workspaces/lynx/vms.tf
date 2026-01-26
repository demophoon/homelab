module "vm-lynx" {
  source = "../../modules/proxmox_vm"
  resource = "module.vm-lynx"

  proxmox_node_prefix = "lynx"
  proxmox_node_name = "lynx"
  proxmox_host = "192.168.1.149"
  is_server = "true"

  cpu = 12
  memory = 16384
  persistant_disk = 64

  proxmox_ssh_user = var.proxmox_ssh_user
  proxmox_ssh_password = var.proxmox_ssh_password
  template_name = data.tfe_outputs.prod_home.values.lynx_template_id

  tailscale_tailnet_name = var.tailscale_tailnet_name
  workspace = "lynx-primary"
  backplane_certificate = data.tfe_outputs.prod_home.values.backplane_certificate

  register_reprovision = true
  reprovision_dow      = 2
}
