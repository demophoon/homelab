terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.114.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.9.1"
    }
    null = {
      source = "hashicorp/null"
      version = "3.3.2"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_host}:8006/"
}
