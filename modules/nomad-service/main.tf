terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.6.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.9.0"
    }
  }
}

provider "nomad" {
  region = "global"
}
