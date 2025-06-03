terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
