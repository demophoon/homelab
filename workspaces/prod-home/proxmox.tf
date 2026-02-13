resource "proxmox_virtual_environment_storage_directory" "default_storage_cascadia" {
  id    = "local"
  path  = "/var/lib/vz"

  content = ["snippets", "backup", "vztmpl", "iso"]
  shared  = false
  disable = false
}

resource "proxmox_virtual_environment_storage_directory" "default_storage_lynx" {
  provider           = proxmox.proxmox-lynx

  id    = "local"
  path  = "/var/lib/vz"

  content = ["import", "snippets", "backup", "vztmpl", "iso"]
  shared  = false
  disable = false
}

resource "proxmox_virtual_environment_sdn_zone_simple" "lynx-sdn" {
  provider = proxmox.proxmox-lynx

  id       = "lynx"
  nodes    = ["lynx"]
}
