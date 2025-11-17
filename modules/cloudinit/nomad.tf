locals {
  nomad_config = templatefile(
    "${path.module}/templates/nomad.hcl",
    {
      region      = var.nomad_region
      provider    = var.nomad_provider
      workspace   = var.workspace
      is_server   = var.server
      include_mounts = var.nomad_region == "cascadia" ? true : false
      include_keepalived = var.nomad_region == "cascadia" ? true : false

      pv_name    = var.pv_name
    }
  )
}
