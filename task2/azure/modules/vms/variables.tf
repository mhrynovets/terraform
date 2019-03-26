# Define the common tags for all resources in module
locals {
  common_tags = {
    //"Component" = "task2-module-${var.prefix}-${random_id.key_id.dec}"
    "Component" = "task2-module-${local.prefix}"
  }
  prefix = "${var.res-prefix == "tfvmex-mod" ? "${var.res-prefix}-${random_id.key_id.dec}" : "${var.res-prefix}" }"
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
variable "rg-name" {
  description = "Define name of pre-existed resource group for VMs"
  default     = "zz"
}
variable "count_instances" {
  description = "Count of vms to be created"
  default     = "1"
}


// Availability set variables
variable "existent_aset_id" {
  description = "Define name of pre-existed availability set to attach VMs to."
  default     = "no"
}


// Network interface (NIC) variables
variable "nsg_id" {
  description = "A Network Security Group ID to attach to the network interface"
  default = ""
}
variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
}


// Public IP (PIP) variables
variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = [""]
}
variable "create_public_ip" {
  description = "Create public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  default     = "0"
}
variable "public_ip_address_allocation" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Dynamic"
}


// Virtual machines (VMs) variables
variable "vms_sku" {
  description = "Choose vm_size of vms"
  default     = "Standard_B1ms"
}
variable "osimage" {
  description = "Choose OS of vms, formatting like 'Canonical,UbuntuServer,18.04-LTS,latest'"
  default = "Canonical,UbuntuServer,18.04-LTS,latest"
}
variable "uname" {
  description = "Username to login per SSH"
  default = "devops"
}
variable "upassword" {
  description = "Password to login per SSH"
}
