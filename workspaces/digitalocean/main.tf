terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.6.1"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.100.0"
    }
    google = {
      source = "hashicorp/google"
      version = "7.46.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.80.0"
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
