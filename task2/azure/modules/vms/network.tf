
resource "azurerm_network_interface" "mod_nic" {
  count                     = "${var.count_instances}"
  name                      = "${local.prefix}-nic-${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${local.rg-name}"
  network_security_group_id = "${var.nsg_id}"

  ip_configuration {
    name                          = "ipconfig-${count.index}"
    subnet_id                     = "${var.vnet_subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${length(azurerm_public_ip.mod_pip.*.id) > 0 ? element(concat(azurerm_public_ip.mod_pip.*.id, list("")), count.index) : ""}"
  }
  depends_on = ["azurerm_resource_group.mod-rg"]
}


resource "azurerm_public_ip" "mod_pip" {
  count                = "${var.create_public_ip == "0" ? "0" : var.count_instances}"
  name                 = "${local.prefix}-pip-${count.index}"
  location             = "${var.location}"
  resource_group_name  = "${local.rg-name}"
  allocation_method    = "${var.public_ip_address_allocation}"
  domain_name_label    = "${element(var.public_ip_dns, count.index)}"
  depends_on = ["azurerm_resource_group.mod-rg"]
}
