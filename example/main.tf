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

provider "gandi" {
  key = var.gandi_key
}

provider "vultr" {
  api_key = var.vultr_api_key
  rate_limit = 700
  retry_limit = 3
}

module "test" {
  source                = "./.."
  gandi_key             = var.gandi_key
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