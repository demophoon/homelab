terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "8.2.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.100.0"
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
