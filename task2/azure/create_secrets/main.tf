data "azurerm_client_config" "current" {}

locals{
  rg-name = "tf-service"
  location = "westeurope"
}

resource "azurerm_key_vault" "test" {
  name                = "tf-data-kv"
  location            = "${local.location}"
  resource_group_name = "${local.rg-name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

    key_permissions = [
      "create",
      "get",
      "update"
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
    ]
  }
}

resource "tls_private_key" "main-tls" {
  algorithm = "RSA"
}

resource "local_file" "sshkey" {
  content     = "${tls_private_key.main-tls.private_key_pem}"
  filename = "demo.pem"
}
resource "local_file" "sshpub" {
  content     = "${tls_private_key.main-tls.public_key_openssh}"
  filename = "demo.pem.pub"
}

resource "azurerm_key_vault_secret" "test" {
  name     = "vms-ssh-key"
  value    = "${tls_private_key.main-tls.private_key_pem}"
  key_vault_id = "${azurerm_key_vault.test.id}"
}

resource "azurerm_key_vault_secret" "test2" {
  name     = "vms-ssh-pub"
  value    = "${tls_private_key.main-tls.public_key_openssh}"
  key_vault_id = "${azurerm_key_vault.test.id}"
}


output "tenant_id" {
  value = "${data.azurerm_client_config.current.tenant_id}"
}
output "client_id" {
  value = "${data.azurerm_client_config.current.client_id}"
}
output "service_principal_object_id" {
  value = "${data.azurerm_client_config.current.service_principal_object_id}"
}
