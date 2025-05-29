terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.3.1"
    }
  }
}

provider "nomad" {
  address = "https://nomad-ui.internal.demophoon.com"
  region = "global"
  alias = "global"
}

provider "nomad" {
  address = "https://nomad-do.internal.demophoon.com"
  region = "digitalocean"
  alias = "digitalocean"
  skip_verify = true
}
