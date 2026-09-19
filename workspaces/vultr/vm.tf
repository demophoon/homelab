module "vm-vultr" {
  source = "../../modules/vultr"

  resource  = "module.vm-vultr"
  workspace = "vultr"

  gcp_zone = data.tfe_outputs.prod_home.values.google_dns_managed_zone_demophoon_com

  region = "sea"
  size   = "vc2-2c-2gb"

  backplane_certificate = data.tfe_outputs.prod_home.values.backplane_certificate

  register_reprovision = true
  reprovision_dow      = 0
  persistant_disk      = 32
}

module "vultr-reprovision" {
  source = "../../modules/reprovisioner"
  workspace = "vultr"
}
