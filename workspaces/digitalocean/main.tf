terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.60.0"
    }
    google = {
      source = "hashicorp/google"
      version = "6.45.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.68.1"
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
