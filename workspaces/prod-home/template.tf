variable "ubuntu_image" {
  type = object({
    url = string
    file_name = string
    #sha256 = string
  })
  default = {
    url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    file_name = "noble-server-cloudimg.img"
    #sha256    = "bc471ca49de03b5129c65b70f9862b7f4b5e721622fd34ade78132f6f7999e2d"
    #url = "https://cloud-images.ubuntu.com/noble/20250226/noble-server-cloudimg-amd64.img"
    #sha256 = "9856e7bdfc4ebc85ff9b21c1cad2de35e6fa7abc2241401ee496e11b290243de"
  }
}

resource "proxmox_virtual_environment_download_file" "nuc_ubuntu_2404_noble_img" {
  content_type       = "iso"
  datastore_id       = "local"
  node_name          = "nuc"
  file_name          = var.ubuntu_image.file_name
  url                = var.ubuntu_image.url
  #checksum           = var.ubuntu_image.sha256
  #checksum_algorithm = "sha256"
  overwrite          = false
}

resource "proxmox_virtual_environment_download_file" "sol_ubuntu_2404_noble_img" {
  content_type       = "iso"
  datastore_id       = "local"
  node_name          = "sol"
  file_name          = var.ubuntu_image.file_name
  url                = var.ubuntu_image.url
  #checksum           = var.ubuntu_image.sha256
  #checksum_algorithm = "sha256"
  overwrite          = false
}

resource "proxmox_virtual_environment_download_file" "lynx_ubuntu_2404_noble_img" {
  provider           = proxmox.proxmox-lynx

  content_type       = "iso"
  datastore_id       = "local"
  node_name          = "lynx"
  file_name          = var.ubuntu_image.file_name
  url                = var.ubuntu_image.url
  #checksum           = var.ubuntu_image.sha256
  #checksum_algorithm = "sha256"
  overwrite          = false
}
