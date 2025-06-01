terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.46.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.54.0"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.13.5"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.5.0"
    }
  }
}
