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
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.54.0"
    }
    google = {
      source = "hashicorp/google"
      version = "6.37.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.66.0"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "sol-aux"
    }
  }
}
