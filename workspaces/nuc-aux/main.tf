terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.66.0"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "nuc-aux"
    }
  }
}
