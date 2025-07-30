terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.5.0"
    }
  }
}

provider "nomad" {
  #address = "https://nomad-do.internal.demophoon.com"
  address = "https://100.110.55.2:4646"
  region = "digitalocean"
  skip_verify = true
}
