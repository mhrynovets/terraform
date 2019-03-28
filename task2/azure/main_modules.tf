provider "azurerm" {
  version = "~> 1.23"
}

resource "azurerm_resource_group" "main-rg" {
  name      = "${local.res-group-name}"
  location  = "${var.location}"
  tags = "${merge(
    local.common_tags,
    map(
      "custom-rg-tag", "${local.res-group-name}-rg"
    )
  )}"
}

module "vnet" {
  source = "modules/vnet"

  res-prefix = "${var.prefix}"
  rg-name = "${azurerm_resource_group.main-rg.name}"
  location  = "${var.location}"
}

module "vms" {
  source = "modules/vms"

  rg-name = "${azurerm_resource_group.main-rg.name}"
  location  = "${var.location}"
  res-prefix = "${var.prefix}"

  uname = "${var.uname}"
  upassword = "${var.upass}"

  vnet_subnet_id = "${element(module.vnet.out-subnet-ids, 0)}"
  count_instances = "${var.vms_count}"
  provision_shell = "${var.web_shell}"
  tags = "${local.common_tags}"
  ky-ssh-pub-name-prefix = "${var.ky-ssh-pub-name-prefix}"
}

module "lb" {
  source = "modules/loadbalancer"
  
  rg-name = "${azurerm_resource_group.main-rg.name}"
  location  = "${var.location}"
  res-prefix = "${var.prefix}"

  dnsforpubip = "${var.domain_name_lb}"
  nic_ids = "${module.vms.out-nic_ids}"
  nic_count = "${var.vms_count}"
}

data "azurerm_key_vault" "keyvault" {
  name                = "${var.kv-name}"
  resource_group_name = "${var.kv-rg}"
}

data "azurerm_key_vault_secret" "ssh_key" {
  name      = "${var.ky-ssh-key-name-prefix}-${ lower(local.common_tags["Environment"]) }"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

resource "null_resource" "copy-test-file" {
  count = "${var.vms_count}"

  connection {
    host      = "${join("", module.lb.out-pip_fqdn)}"
    user      = "${var.uname}"
    private_key = "${data.azurerm_key_vault_secret.ssh_key.value}"
    //password  = "${var.upass}"
    type      = "ssh"
    port      = "837${count.index}"
  }
  provisioner "remote-exec" {
    inline = [
      "${var.web_shell}"
    ]
  }
  depends_on = [
    "module.vms", 
    "module.lb"
  ]
}
