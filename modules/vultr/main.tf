terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "2.32.0"
    }
  }
}
