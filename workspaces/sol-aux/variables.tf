variable "proxmox_ssh_user" { }
variable "proxmox_ssh_password" {
  sensitive = true
}
variable "tailscale_tailnet_name" { }
