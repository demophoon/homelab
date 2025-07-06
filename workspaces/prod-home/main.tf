terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.79.0"
    }
    truenas = {
      source = "dariusbakunas/truenas"
      version = "0.11.1"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.21.1"
    }
    google = {
      source = "hashicorp/google"
      version = "6.42.0"
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
