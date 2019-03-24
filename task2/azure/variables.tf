
# Define the common tags for all resources
locals {
  common_tags = {
    Component   = "task2"
    Environment = "dev"
    orchestrator = "terra"
  }
}

variable "prefix" {
  description = "Resources naming prefix"
  default = "tfvmex"
}

variable "location" {
  description = "Which cloud region should be used"
  default = "West US 2"
}

variable "vms_count" {
  description = "How much VMs are needed"
  default = 1
}


variable "dnsforpubip" {
  description = "Which cloud region should be used"
  default = "demo-pubdns-terra"
}

variable "osimage" {
  description = "Which OS on VMs to use"
  default = "debian-cloud/debian-8"
}