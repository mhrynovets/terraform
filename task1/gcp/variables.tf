
variable "prefix" {
  description = "Resources naming prefix"
  default = "tfvmex"
}

variable "region" {
  description = "Which cloud region should be used"
  default = "europe-west3"
}

variable "zone" {
  description = "Which zone in cloud region should be used"
  default = "europe-west3-b"
}

variable "osimage" {
  description = "Which OS on VMs to use"
  default = "debian-cloud/debian-8"
}
