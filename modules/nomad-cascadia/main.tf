terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.0"
    }
  }
}

provider "nomad" {
  address = "https://nomad-ui.internal.demophoon.com"
  #address = "https://100.95.210.88:4646"
  region = "global"
}
