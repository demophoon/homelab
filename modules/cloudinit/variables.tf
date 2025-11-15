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
