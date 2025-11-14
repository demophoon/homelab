variable "hostname" {}
variable "nomad_region" {}
variable "nomad_provider" {}
variable "server" {
  default = false
}

variable "pv_name" {}

# For terraform automation
variable "resource" {}
variable "workspace" {}
