terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.20.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.0.0"
    }
  }
}
