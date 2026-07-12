terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.6.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.10.1"
    }
  }
}

provider "nomad" {
  region = "global"
}
