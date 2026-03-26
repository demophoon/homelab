variable "gcp_zone" {}

variable "size" {}
variable "is_server" {
  default = false
}
variable "join_nodes" {
  default = []
}
variable "resource" {}
variable "workspace" {}

variable "persistant_disk" {
  description = "Number of GB to reserve in a virtual disk which follows automatically mounts to vms created by this workspace"
  default = 0
}

variable "created_at" {
  description = "Timestamp used to force VM recreation when needed"
  default = null
}

variable "backplane_certificate" { }

variable "register_reprovision" {
  description = "Registers a Nomad job which will reprovision this machine automatically on a schedule"
  default = false
}
variable "reprovision_dow" {
  description = "Day of week to schedule reprovisioning on (0-6, Sunday-Saturday)"
  default     = 0
}
