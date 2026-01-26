locals {
  keepalive_priority = contains([
    "lynx",
    "lynx-secondary",
  ], var.workspace)
}
resource "random_integer" "vrrp_priority" {
  min = local.keepalive_priority ? 1 : 127
  max = local.keepalive_priority ? 128 : 254
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
