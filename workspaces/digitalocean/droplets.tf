module "vm-do" {
  for_each = {
    b = {
      size = "s-2vcpu-2gb-intel"
      #size = "s-1vcpu-1gb-intel"
      server = false
    }
# Backups below
    #e = {
    #  size = "s-1vcpu-1gb-intel"
    #  size = "s-1vcpu-512mb-10gb"
    #  server = false
    #}
    #f = {
    #  size = "s-1vcpu-1gb-intel"
    #  server = false
    #}
    #g = {
    #  size = "s-1vcpu-1gb-intel"
    #  server = true
    #}
  }
  source = "../../modules/digitalocean"
  resource = "module.vm-do"
  workspace = "digitalocean"

  gcp_zone = data.tfe_outputs.prod_home.values.google_dns_managed_zone_demophoon_com
  size = each.value.size
  is_server = each.value.server

  backplane_certificate = data.tfe_outputs.prod_home.values.backplane_certificate
  register_reprovision = true
  reprovision_dow      = 0
}

module "digitalocean-reprovision" {
  source = "../../modules/reprovisioner"
  workspace = "digitalocean"
}
