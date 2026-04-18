terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.28.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.84.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.8.1"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
