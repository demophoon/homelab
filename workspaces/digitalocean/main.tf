terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.2"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.72.0"
    }
    google = {
      source = "hashicorp/google"
      version = "6.50.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.73.0"
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
