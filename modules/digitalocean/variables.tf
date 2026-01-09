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

variable "backplane_certificate" { }

variable "register_reprovision" {
  description = "Registers a Nomad job which will reprovision this machine automatically on a schedule"
  default = false
}
variable "reprovision_dow" {
  description = "Day of week to schedule reprovisioning on (0-6, Sunday-Saturday)"
  default     = 0
}
