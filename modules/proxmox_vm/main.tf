terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.0"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.20.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.0.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
