terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.58.0"
    }
    google = {
      source = "hashicorp/google"
      version = "6.42.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.67.1"
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
