# Define the common tags for all resources in module
locals {
  common_module_tags = { "Component" = "task2-module-${local.prefix}" }
  prefix = "${var.res-prefix == "tfvmex-mod" ? "${var.res-prefix}-${format("subnet-%06d", random_id.key_id.dec)}" : "${var.res-prefix}" }"
  rg-name = "${var.rg-name == "zz-noname" ? "${join("", azurerm_resource_group.mod-rg.*.name)}" : "${var.rg-name}" }"
  vnet-name = "${var.existing_vname == "zz-noname" ? "${join("", azurerm_virtual_network.mod-vnet.*.name)}" : "${var.existing_vname}" }"
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


// Resource group variables
variable "rg-name" {
  description = "Define name of pre-existed resource group for VMs"
  default     = "zz-noname"
}


// Virtual network (vnet) variables
variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}
variable "existing_vname" {
  description = "The address space that is used by the virtual network."
  default     = "zz-noname"
}


// Subnet (vnet) variables
variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = [""]
}
variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}
