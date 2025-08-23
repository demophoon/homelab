terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.66.0"
    }
    google = {
      source = "hashicorp/google"
      version = "6.49.2"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.68.2"
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
