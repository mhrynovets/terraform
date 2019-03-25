resource "azurerm_public_ip" "lbpip" {
  name                = "${var.prefix}-lb-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main-rg.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.dnsforpubip}-lb"
}

resource "azurerm_lb" "main-lb" {
  resource_group_name = "${azurerm_resource_group.main-rg.name}"
  name                = "${var.prefix}-lb"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.main-rg.name}"
  loadbalancer_id     = "${azurerm_lb.main-lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${azurerm_resource_group.main-rg.name}"
  loadbalancer_id                = "${azurerm_lb.main-lb.id}"
  name                           = "SSH-VM-${count.index +1}"
  protocol                       = "tcp"
  frontend_port                  = "3300${count.index +1}"
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  //frontend_ip_configuration_name = "${azurerm_lb.main-lb.frontend_ip_configuration_name}"
  count                          = "${var.vms_count}"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.main-rg.name}"
  loadbalancer_id     = "${azurerm_lb.main-lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.main-rg.name}"
  loadbalancer_id                = "${azurerm_lb.main-lb.id}"
  name                           = "webBalanceRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  //frontend_ip_configuration_name = "${azurerm_lb.main-lb.frontend_ip_configuration_name}"
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_network_interface_backend_address_pool_association" "nic-lb-backend" {
  network_interface_id    = "${element(azurerm_network_interface.main-nic.*.id, count.index)}"
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  count                   = "${var.vms_count}"

  depends_on = ["azurerm_network_interface.main-nic"]
}

