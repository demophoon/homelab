terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.6.1"
    }
    google = {
      source = "hashicorp/google"
      version = "8.4.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.81.0"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "vultr"
    }
  }
}
