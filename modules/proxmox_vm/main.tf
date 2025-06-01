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
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.8.0"
    }
  }
}
