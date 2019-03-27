data "azurerm_key_vault" "keyvault" {
  name                = "tf-data-kv"
  resource_group_name = "tf-service"
}

data "azurerm_key_vault_secret" "test" {
  name      = "vms-ssh-pub"
  vault_uri = "${data.azurerm_key_vault.keyvault.vault_uri}"
}

output "secret_value" {
  value = "${data.azurerm_key_vault_secret.test.value}"

}
