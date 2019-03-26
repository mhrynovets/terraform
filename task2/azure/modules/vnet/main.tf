
resource "random_id" "key_id" {
  count     = "${var.res-prefix == "tfvmex-mod" ? 1 : 0}"
  byte_length = 2
}

resource "azurerm_resource_group" "mod-rg" {
  count     = "${var.rg-name == "zz-noname" ? 1 : 0}"
  name      = "${local.prefix}-rg"
  location  = "${var.location}"
  tags = "${merge(
    var.tags,
    local.common_module_tags,
    map(
      "custom-rg-tag", "${local.prefix}-rg"
    )
  )}"
}

resource "azurerm_virtual_network" "mod-vnet" {
  count               = "${var.existing_vname == "zz-noname" ? 1 : 0}"
  name                = "${local.prefix}-vnet"
  address_space       = ["${var.address_space}"]
  location            = "${var.location}"
  resource_group_name = "${local.rg-name}"
  tags = "${merge(
    var.tags,
    local.common_module_tags,
    map(
      "custom-vnet-tag", "${local.prefix}-vnet"
    )
  )}"  
}

resource "azurerm_subnet" "mod-subnet" {
  count                 = "${length(var.subnet_prefixes)}"
  name                  = "${join("", var.subnet_names) == "" ? "${format("subnet-%02d", count.index + 1)}" : var.subnet_names[count.index]}"
  resource_group_name   = "${local.rg-name}"
  virtual_network_name  = "${local.vnet-name}"
  address_prefix        = "${var.subnet_prefixes[count.index]}"
}
