terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.9.1"
    }
    gandi = {
      source = "psychopenguin/gandi"
      version = "2.0.0-rc3"
    }
  }
}

# provider "gandi" {
#   key = var.gandi_key
# }

# provider "vultr" {
#   api_key = var.vultr_api_key
#   rate_limit = 700
#   retry_limit = 3
# }