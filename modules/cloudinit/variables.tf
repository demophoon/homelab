variable "hostname" {}
variable "nomad_region" {}
variable "nomad_provider" {}
variable "server" {
  default = false
}

variable "pv_name" {
  default = ""
}

# For terraform automation
variable "resource" {}
variable "workspace" {}

variable "backplane_certificate" {}

variable "use_miren" {
  default = false
}

variable "register_reprovision" {
  description = "Registers a Nomad job which will reprovision this machine automatically on a schedule"
  default = false
}
