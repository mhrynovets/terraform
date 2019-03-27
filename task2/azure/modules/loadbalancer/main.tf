
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
    local.common_tags,
    map(
      "custom-rg-tag", "${local.prefix}-rg"
    )
  )}"
}


resource "azurerm_public_ip" "lbpip" {
  name                = "${local.prefix}-lb-ip"
  location            = "${var.location}"
  resource_group_name = "${local.rg-name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.dnsforpubip}-lb"
}

resource "azurerm_lb" "lb" {
  resource_group_name = "${local.rg-name}"
  name                = "${local.prefix}-lb"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backendpool" {
  resource_group_name = "${local.rg-name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${local.rg-name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "SSH-VM-${count.index +1}"
  protocol                       = "tcp"
  frontend_port                  = "3300${count.index +1}"
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  count                          = "${var.nic_count}"
}

resource "azurerm_lb_probe" "lbprobe" {
  resource_group_name = "${local.rg-name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lbrule" {
  resource_group_name            = "${local.rg-name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "webBalanceRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backendpool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lbprobe.id}"
  depends_on                     = ["azurerm_lb_probe.lbprobe"]
}

resource "azurerm_network_interface_backend_address_pool_association" "nic-lb-backend" {
  network_interface_id    = "${element(var.nic_ids, count.index)}"
  ip_configuration_name   = "ipconfig-${count.index}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.backendpool.id}"
  count                   = "${var.nic_count}"
}
