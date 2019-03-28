data "azurerm_client_config" "current" {}

locals{
  rg-name = "tf-service"
  location = "westeurope"
  kv-name = "tf-data-kv-2"
}

resource "azurerm_key_vault" "test" {
  name                = "${local.kv-name}"
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

resource "tls_private_key" "prod-tls" {
  algorithm = "RSA"
}

resource "tls_private_key" "dev-tls" {
  algorithm = "RSA"
}


//save to file to be available manual connect ssh 
resource "local_file" "sshkey-prod" {
  content     = "${tls_private_key.prod-tls.private_key_pem}"
  filename = "demo-prod.pem"
}

resource "local_file" "sshkey-dev" {
  content     = "${tls_private_key.dev-tls.private_key_pem}"
  filename = "demo-dev.pem"
}

resource "local_file" "sshpub-prod" {
  content     = "${tls_private_key.prod-tls.public_key_openssh}"
  filename = "demo-prod.pem.pub"
}

resource "local_file" "sshpub-dev" {
  content     = "${tls_private_key.dev-tls.public_key_openssh}"
  filename = "demo-dev.pem.pub"
}



resource "azurerm_key_vault_secret" "save-key-prod" {
  name     = "vms-ssh-key-prod"
  value    = "${tls_private_key.prod-tls.private_key_pem}"
  key_vault_id = "${azurerm_key_vault.test.id}"
}

resource "azurerm_key_vault_secret" "save-key-dev" {
  name     = "vms-ssh-key-dev"
  value    = "${tls_private_key.dev-tls.private_key_pem}"
  key_vault_id = "${azurerm_key_vault.test.id}"
}

resource "azurerm_key_vault_secret" "save-pub-prod" {
  name     = "vms-ssh-pub-prod"
  value    = "${tls_private_key.prod-tls.public_key_openssh}"
  key_vault_id = "${azurerm_key_vault.test.id}"
}

resource "azurerm_key_vault_secret" "save-pub-dev" {
  name     = "vms-ssh-pub-dev"
  value    = "${tls_private_key.dev-tls.public_key_openssh}"
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
