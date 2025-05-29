terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.75.0"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.13.5"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.5.0"
    }
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.19"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.25.2"
    }
    google = {
      source = "hashicorp/google"
      version = "4.46.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.52.0"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "nuc"
    }
  }
}
