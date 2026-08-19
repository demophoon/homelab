terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.6.1"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.99.1"
    }
    google = {
      source = "hashicorp/google"
      version = "7.43.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.79.0"
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
