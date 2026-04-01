terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.76.0"
    }
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "lynx-primary"
    }
  }
}
