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

provider "digitalocean" {
  token = var.digitalocean_key
}

provider "vultr" {
  api_key = var.vultr_api_key
  rate_limit = 700
  retry_limit = 3
}

module "test" {
  source                = "./.."
  digitalocean_key      = var.digitalocean_key
  vultr_api_key         = var.vultr_api_key
  stack_name            = var.stack_name
  root_domain           = var.root_domain
  ssh_authorized_key    = var.ssh_authorized_key
  env                   = var.env
  hostname              = var.hostname
  nixos_iso_vultr_id    = var.nixos_iso_vultr_id
  vultr_instance_region = var.vultr_instance_region
  vultr_instance_plan   = var.vultr_instance_plan
  ssh_port              = var.ssh_port
}