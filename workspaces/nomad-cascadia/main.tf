terraform {
  required_providers {
  }

  cloud {
    organization = "demophoon"
    hostname = "app.terraform.io"

    workspaces {
      name = "nomad-cascadia"
    }
  }
}
