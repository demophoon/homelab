terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.79.0"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "lynx-secondary"
    }
  }
}
