terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.2"
    }
  }
}

provider "nomad" {
  address = "https://nomad-ui.internal.demophoon.com"
  region = "global"
}
