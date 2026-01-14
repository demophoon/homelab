terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.73.0"
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
