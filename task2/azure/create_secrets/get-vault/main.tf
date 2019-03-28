data "azurerm_key_vault" "keyvault" {
  name                = "tf-data-kv-2"
  resource_group_name = "tf-service"
}

data "azurerm_key_vault_secret" "ssh_pub" {
  name      = "vms-ssh-pub-prod"
  // deprecated: vault_uri = "${data.azurerm_key_vault.keyvault.vault_uri}"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

output "secret_value" {
  value = "${data.azurerm_key_vault_secret.ssh_pub.value}"
}
