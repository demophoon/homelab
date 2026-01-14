variable "proxmox_node_prefix" { }
variable "proxmox_node_name" { }
variable "proxmox_host" { }
variable "proxmox_ssh_user" { }
variable "proxmox_ssh_password" {
  sensitive = true
}

variable "tailscale_tailnet_name" { }

variable "template_name" { }
variable "is_server" {
  default = "true"
}

variable "cpu" {
  default = 8
}
variable "memory" {
  default = 16384
}
variable "persistant_disk" {
  description = "Number of GB to reserve in a virtual disk which follows automatically mounts to vms created by this workspace"
  default = 32
}

variable "join_nodes" {
  default = []
}

variable "resource" {
  default = ""
}
variable "workspace" { }

variable "backplane_certificate" { }

variable "use_miren" {
  default = false
}

variable "register_reprovision" {
  description = "Registers a Nomad job which will reprovision this machine automatically on a schedule"
  default = false
}
variable "reprovision_dow" {
  description = "Day of week to schedule reprovisioning on (0-6, Sunday-Saturday)"
  default     = 3
}
