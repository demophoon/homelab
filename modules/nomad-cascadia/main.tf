terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.6.1"
    }
  }
}

provider "nomad" {
  region = "global"
}
