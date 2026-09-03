output "google_dns_managed_zone_brittslittlesliceofheaven_org" {
  description = "Google DNS Managed Zone name for brittslittlesliceofheaven.org"
  value = google_dns_managed_zone.brittslittlesliceofheaven_org.name
}

output "google_dns_managed_zone_demophoon_com" {
  description = "Google DNS Managed Zone name for demophoon.com"
  value = google_dns_managed_zone.demophoon_com.name
}

output "google_dns_managed_zone_brittg_com" {
  description = "Google DNS Managed Zone name for brittg.com"
  value = google_dns_managed_zone.brittg_com.name
}

output "google_dns_managed_zone_flawedfauna_com" {
  description = "Google DNS Managed Zone name for flawedfauna.com"
  value = google_dns_managed_zone.flawedfauna_com.name
}

output "lynx_template_id" {
  description = "vmid for lynx"
  value = proxmox_virtual_environment_download_file.lynx_ubuntu_2604_resolute_img.id
}

output "backplane_certificate" {
  description = "Vault PKI Backplane Certificate"
  value       = module.vault.backplane_certificate
}
