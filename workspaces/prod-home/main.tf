terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.97.1"
    }
    truenas = {
      source = "dariusbakunas/truenas"
      version = "0.11.1"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.28.0"
    }
    google = {
      source = "hashicorp/google"
      version = "7.21.0"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "prod-home"
    }
  }
  #backend "s3" {
  #  s3     = "s3.us-west-001.backblazeb2.com"
  #  bucket = "demophoon-state"
  #  key    = "states/prod-home"
  #  region = "us-west-001"
  #}
}

provider "proxmox" {
  alias = "proxmox-lynx"
  endpoint = "https://192.168.1.149:8006/"
}
