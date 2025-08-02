terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.68.2"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "sol-aux"
    }
  }
}
