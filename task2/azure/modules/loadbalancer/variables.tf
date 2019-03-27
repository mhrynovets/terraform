# Define the common tags for all resources in module
locals {
  common_tags = {
    //"Component" = "task2-module-${var.prefix}-${random_id.key_id.dec}"
    "Component" = "task2-module-${local.prefix}"
  }
  prefix = "${var.res-prefix == "tfvmex-mod" ? "${var.res-prefix}-${join("",random_id.key_id.*.dec)}" : "${var.res-prefix}" }"
  rg-name = "${var.rg-name == "zz-noname" ? "${join("", azurerm_resource_group.mod-rg.*.name)}" : "${var.rg-name}" }"
  nicids = "${var.nic_ids}"
}

// Global vars
variable "tags" {
  type    = "map"
  default = {
    orchestrator = "terra"
  }
}
variable "res-prefix" {
  description = "Resources naming prefix"
  default = "tfvmex-mod"
}
variable "location" {
  description = "Which cloud region should be used"
  default = "West US 2"
}
variable "count_instances" {
  description = "Count of vms to be created"
  default     = "1"
}


// Resource group variables
variable "rg-name" {
  description = "Define name of pre-existed resource group for VMs"
  default     = "zz-noname"
}


variable "dnsforpubip" { }


variable "nic_ids" { 
  default     = [""]
}

variable "nic_count" { }
