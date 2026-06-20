terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.109.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.9.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.3.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_host}:8006/"
}
