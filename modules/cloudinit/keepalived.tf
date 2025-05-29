resource "random_integer" "vrrp_priority" {
  min = 1
  max = 255
  keepers = {
    vm = var.hostname
  }
}

locals {
  keepalived_config = templatefile(
    "${path.module}/templates/keepalived.conf",
    {
      vrrp_priority = random_integer.vrrp_priority.result
    }
  )
}
