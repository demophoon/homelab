data "tailscale_devices" "proxmox" {
  name_prefix = "proxmox-"
}

resource "google_dns_record_set" "demophoon-ts" {
  name         = "*.ts.demophoon.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.demophoon_com.name

  rrdatas = [for device in data.tailscale_devices.proxmox.devices: device.addresses[0]]
}

