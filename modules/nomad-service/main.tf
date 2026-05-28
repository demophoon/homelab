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
    uptimekuma = {
      source  = "breml/uptimekuma"
      version = "0.3.2"
    }
  }
}

provider "nomad" {
  region = "global"
}

provider "uptimekuma" {
  endpoint = "https://status.internal.demophoon.com"
  username = "demophoon"
  password = "FJZLAa5PBEKQUjbQMcEDRCorVi"
}
