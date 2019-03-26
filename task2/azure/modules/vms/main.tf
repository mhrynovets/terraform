resource "random_id" "key_id" {
  byte_length = 2
}

resource "azurerm_resource_group" "mod-rg" {
  count     = "${var.rg-name == "zz" ? 1 : 0}"
  name      = "${local.prefix}-rg"
  location  = "${var.location}"
  tags = "${merge(
    var.tags,
    local.common_tags,
    map(
      "custom-rg-tag", "${local.prefix}-rg"
    )
  )}"
}


resource "azurerm_availability_set" "mod-aset" {
  count = "${var.existent_aset_id == "no" ? 1 : 0}"  
  name                         = "${local.prefix}-aset"
  location                     = "${var.location}"
  resource_group_name          = "${var.rg-name == "zz" ? "${join("", azurerm_resource_group.mod-rg.*.name)}" : "${var.rg-name}" }"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 10
  managed                      = true
  tags = "${merge(
    var.tags,
    local.common_tags,
    map(
      "custom-aset-tag", "${local.prefix}-aset"
    )
  )}"
  depends_on = ["azurerm_resource_group.mod-rg"]
}


resource "azurerm_network_interface" "mod_nic" {
  count                     = "${var.count_instances}"
  name                      = "${local.prefix}-nic-${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${var.rg-name == "zz" ? "${join("", azurerm_resource_group.mod-rg.*.name)}" : "${var.rg-name}" }"
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
  resource_group_name  = "${var.rg-name == "zz" ? "${join("", azurerm_resource_group.mod-rg.*.name)}" : "${var.rg-name}" }"
  allocation_method    = "${var.public_ip_address_allocation}"
  domain_name_label    = "${element(var.public_ip_dns, count.index)}"
  depends_on = ["azurerm_resource_group.mod-rg"]
}




resource "azurerm_virtual_machine" "mod-vms" {
  count                 = "${var.count_instances}"
  name                  = "${local.prefix}-vms-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.rg-name == "zz" ? "${join("", azurerm_resource_group.mod-rg.*.name)}" : "${var.rg-name}" }"
  network_interface_ids = ["${element(azurerm_network_interface.mod_nic.*.id, count.index)}"]
  availability_set_id   = "${var.existent_aset_id == "no" ? "${azurerm_availability_set.mod-aset.id}" : "${var.existent_aset_id}" }"
  vm_size               = "${var.vms_sku}"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${element(split(",", var.osimage), 0)}"
    offer     = "${element(split(",", var.osimage), 1)}"
    sku       = "${element(split(",", var.osimage), 2)}"
    version   = "${element(split(",", var.osimage), 3)}"
  }
  storage_os_disk {
    name              = "myosdisk-vm-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.create_public_ip == "0" ? "${local.prefix}-vms-${count.index}" : "${element(var.public_ip_dns, count.index)}" }"
    admin_username = "${var.uname}"
    admin_password = "${var.upassword}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = ["azurerm_resource_group.mod-rg"]
}