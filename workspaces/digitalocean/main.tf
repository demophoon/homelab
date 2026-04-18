terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.6.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.84.1"
    }
    google = {
      source = "hashicorp/google"
      version = "7.28.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.76.2"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "digitalocean"
    }
  }
}
