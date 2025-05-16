variable "gcp_zone" {}

variable "size" {}
variable "is_server" {
  default = false
}
variable "join_nodes" {
  default = []
}
variable "resource" {}
