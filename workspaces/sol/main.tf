terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.76.2"
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
