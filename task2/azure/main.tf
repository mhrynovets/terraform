provider "azurerm" {
  version = "~> 1.23"
}

resource "tls_private_key" "main-tls" {
  algorithm = "RSA"
}

resource "azurerm_resource_group" "main-rg" {
  name     = "${var.prefix}-rg"
  location = "${var.location}"
  tags = "${merge(
    local.common_tags,
    map(
      "custom-rg", "${var.prefix}-rg"
    )
  )}"
}

resource "local_file" "sshkey" {
  content     = "${tls_private_key.main-tls.private_key_pem}"
  filename = "devops.pem"
}
resource "local_file" "sshpub" {
  content     = "${tls_private_key.main-tls.public_key_openssh}"
  filename = "devops.pem.pub"
}
