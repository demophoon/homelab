terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.2"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.81.0"
    }
    google = {
      source = "hashicorp/google"
      version = "7.27.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.76.1"
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
