terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.36.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.89.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.9.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.3.0"
    }
  }
}
