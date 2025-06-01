terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.75.0"
    }
    truenas = {
      source = "dariusbakunas/truenas"
      version = "0.11.1"
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
      version = "3.13.0"
    }
    nomad = {
      source = "hashicorp/nomad"
      version = "2.3.1"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.54.0"
    }
    #vultr = {
    #  source = "vultr/vultr"
    #  version = "2.13.0"
    #}
    google = {
      source = "hashicorp/google"
      version = "4.46.0"
    }
    #oci = {
    #  source = "oracle/oci"
    #  version = "4.105.0"
    #}
    #unifi = {
    #  source = "paultyng/unifi"
    #  version = "0.39.0"
    #}
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
