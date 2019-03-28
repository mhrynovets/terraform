
# Define the common tags for all resources
locals {
  common_tags = {
    Component   = "task2"
    Environment = "dev"
    Orchestrator = "terra"
  }
  res-group-name = "${var.prefix}-rg"
}

variable "uname" {
  description = "Virtual machines admin's username"
  default = "devops"
}

variable "upass" {
  description = "Virtual machines admin's username"
  default = "Password1234!"
}

variable "prefix" {
  description = "Resources naming prefix, shoult NOT contain ` ~ ! @ # $$ % ^ & * ( ) = + _ [ ] { } \\ | ; : ' \" , < > / ?.\""
  default = "testapp"
}

variable "location" {
  description = "Which cloud region should be used"
  default = "West US 2"
}

variable "domain_name_lb" {
  description = "How much VMs are needed"
  default = "1mylbdemq"
}

variable "vms_count" {
  description = "How much VMs are needed"
  default = "1"
}

variable "web_shell" {
  default = [
    "sleep 1"
  ]
}

variable "kv-name" {
  description = "Name of Azure Key Vault storage, where credentials are saved"
  default = "tf-data-kv-2"
}

variable "kv-rg" {
  description = "Name of Resource Group, where Azure Key Vault is stored"
  default = "tf-service"
}

variable "ky-ssh-key-name" {
  description = "Name of secret in Azure Key Vault, where is stored SSH key"
  default = "vms-ssh-key"
}
