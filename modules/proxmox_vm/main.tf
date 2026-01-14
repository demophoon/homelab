terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.93.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.8.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_host}:8006/"
}
