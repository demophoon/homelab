terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "8.3.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.100.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.9.1"
    }
    null = {
      source = "hashicorp/null"
      version = "3.3.2"
    }
  }
}
