terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.38.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.55.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
