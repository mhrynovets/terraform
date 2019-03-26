provider "azurerm" {
  version = "~> 1.23"
}

variable "web_shell" {
  default = [
    "sudo apt-get update > /dev/null 2>&1",
    "sudo apt-get install -yq nginx > /dev/null 2>&1",
    "echo \"Hi, this is VM <strong>$(hostname)</strong> with IP: <strong>$(curl ifconfig.io)</strong>\" | sudo tee /var/www/html/index.html  > /dev/null 2>&1"
  ]
}

module "vnet" {
  source = "modules/vnet"

  res-prefix = "testapp"
}

module "vms" {
  source = "modules/vms"

  rg-name = "${module.vnet.out-rg-name}"
  res-prefix = "testapp"
  upassword = "Password1234!"
  vnet_subnet_id = "${element(module.vnet.out-subnet-ids, 0)}"
  count_instances = "2"
  create_public_ip = "yes"
  nsg_id = "${azurerm_network_security_group.main-nsg.id}"  
  public_ip_dns = [
    "asfdasdsdasfd-1",
    "asfdasdsdasfd-2"
  ]
  provision_shell = "${var.web_shell}"
}


module "lb" {
  source = "modules/loadbalancer"
  
  dnsforpubip = "mylbdemq"
  nic_ids = "${join(",", module.vms.out-nic_ids)}"
  rg-name = "${module.vms.out-rg-name}"
  res-prefix = "testapp"
}







output "testout" {
  value = "${module.vms.out-nic_ids}"
}


resource "azurerm_network_security_group" "main-nsg" {
  name                = "${var.prefix}-nsg"
  location            = "${var.location}"
  resource_group_name = "${module.vnet.out-rg-name}"

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
