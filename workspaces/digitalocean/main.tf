terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.2"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.77.0"
    }
    google = {
      source = "hashicorp/google"
      version = "7.20.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.74.0"
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
