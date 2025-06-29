terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.67.1"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "sol"
    }
  }
}
