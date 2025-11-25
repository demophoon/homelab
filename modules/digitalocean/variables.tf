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
