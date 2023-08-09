variable "gandi_key" {
  type        = string
  description = "gandi key"
}

variable "vultr_api_key" {
  type        = string
  description = "vultr api key"
}

variable "stack_name" {
  type        = string
  description = "name of this stack"
}

variable "root_domain" {
  type = string
}

variable "ssh_authorized_key" {
  type        = string
  description = "ssh public key used to set up the instance"
}

variable "nixos_iso_vultr_id" {
  type        = string
  description = "ID of the nixos installer image uploaded to vultr"
}

variable "env" {
  type        = string
  description = "build environment"
  default     = "dev"
}

variable "hostname" {
  type        = string
  description = "hostname of the deployed instance"
  default     = "nixos"
}

variable "storage_device_prefix" {
  type        = string
  description = "block storage device prefix, should probably be sda, nvme0n1 or vda"
  default     = "vda"
}

variable "vultr_instance_region" {
  type        = string
  description = "region the vultr instance is created in"
  default     = "ewr"
}

variable "vultr_instance_plan" {
  type        = string
  description = "machine size of the created vultr instance"
  default     = "vc2-1c-1gb"
}

variable "ssh_port" {
  type        = string
  description = "ssh port the vultr instance listens on"
  default     = "22"
}

variable "ddos_protection" {
  type        = bool
  description = "enable ddos protection from vultr or not (extra $10usd/mo at time of writing)"
  default     = false
}
