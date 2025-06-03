terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.85.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.54.0"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.20.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.3"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.0.0"
    }
  }
}
