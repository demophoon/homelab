variable "gcp_zone" {}

variable "size" {
  description = "Vultr plan ID, for example vc2-1c-2gb"
}

variable "region" {
  description = "Vultr region ID"
}

variable "os_id" {
  description = "Vultr operating system ID"

  # Ubuntu 26.04 LTS x64
  default     = 2760
}

variable "is_server" {
  default = false
}

variable "join_nodes" {
  default = []
}

variable "resource" {}
variable "workspace" {}

variable "persistant_disk" {
  description = "Number of GB to reserve in a block volume which follows and automatically mounts to VMs created by this workspace"
  default     = 0
}

variable "created_at" {
  description = "Timestamp used to force VM recreation when needed"
  default     = null
}

variable "backplane_certificate" {}

variable "register_reprovision" {
  description = "Registers a Nomad job which will reprovision this machine automatically on a schedule"
  default     = false
}

variable "reprovision_dow" {
  description = "Day of week to schedule reprovisioning on (0-6, Sunday-Saturday)"
  default     = 0
}
