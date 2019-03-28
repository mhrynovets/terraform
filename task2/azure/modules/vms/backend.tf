terraform {
  backend "azurerm" {
    storage_account_name = "tfsaservice"
    container_name       = "terraform"
    key                  = "vms.terraform.tfstate"
  }
}
