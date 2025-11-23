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

output "beryllium_template_id" {
  description = "vmid for beryllium"
  #value = proxmox_virtual_environment_download_file.beryllium_ubuntu_2404_noble_img.id
  value = "local:iso/noble-server-cloudimg-amd64.img"
}

output "nuc_template_id" {
  description = "vmid for nuc"
  #value = proxmox_virtual_environment_download_file.nuc_ubuntu_2404_noble_img.id
  value = "local:iso/noble-server-cloudimg-amd64.img"
}

output "sol_template_id" {
  description = "vmid for sol"
  #value = proxmox_virtual_environment_download_file.sol_ubuntu_2404_noble_img.id
  value = "local:iso/noble-server-cloudimg-amd64.img"
}

output "backplane_certificate" {
  description = "Vault PKI Backplane Certificate"
  value       = module.vault.backplane_certificate
}
