resource "azurerm_network_security_group" "main-nsg" {
  name                = "${var.prefix}-nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main-rg.name}"

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "custom-nsg", "${var.prefix}-nsg"
    )
  )}"  
}

resource "azurerm_virtual_network" "main-vnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main-rg.location}"
  resource_group_name = "${azurerm_resource_group.main-rg.name}"
  tags = "${merge(
    local.common_tags,
    map(
      "custom-vnet", "${var.prefix}-network"
    )
  )}"  
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.main-vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "main-nic" {
  count = "${var.vms_count}"

  name                = "${var.prefix}-nic-${count.index}"
  location            = "${azurerm_resource_group.main-rg.location}"
  resource_group_name = "${azurerm_resource_group.main-rg.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.main-ip.*.id, count.index)}"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "custom-nic", "${var.prefix}-nic"
    )
  )}"  
}

resource "azurerm_public_ip" "main-ip" {
  count = "${var.vms_count}"

  name                = "${var.prefix}-ip-${count.index}"
  location            = "${azurerm_resource_group.main-rg.location}"
  resource_group_name = "${azurerm_resource_group.main-rg.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.dnsforpubip}-${count.index}"

  tags = "${merge(
    local.common_tags,
    map(
      "custom-ip", "${var.prefix}-ip-${count.index}"
    )
  )}"  
}

data "azurerm_public_ip" "main-data-ip" {
  count               = "${var.vms_count}"

  name                = "${element(azurerm_public_ip.main-ip.*.name, count.index)}"
  resource_group_name = "${azurerm_resource_group.main-rg.name}"
}

