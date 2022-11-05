terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.9.1"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.23.0"
    }
  }
}