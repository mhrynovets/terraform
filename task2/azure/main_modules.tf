provider "azurerm" {
  version = "~> 1.23"
}

module "vnet" {
  source = "modules/vnet"

  res-prefix = "${var.prefix}"
}

module "vms" {
  source = "modules/vms"

  rg-name = "${module.vnet.out-rg-name}"
  res-prefix = "${var.prefix}"

  uname = "${var.uname}"
  upassword = "${var.upass}"

  vnet_subnet_id = "${element(module.vnet.out-subnet-ids, 0)}"
  count_instances = "${var.vms_count}"
  provision_shell = "${var.web_shell}"
}

module "lb" {
  source = "modules/loadbalancer"
  
  rg-name = "${module.vms.out-rg-name}"
  res-prefix = "${var.prefix}"

  dnsforpubip = "${var.domain_name_lb}"
  nic_ids = "${module.vms.out-nic_ids}"
  nic_count = "${var.vms_count}"
}

resource "null_resource" "copy-test-file" {
  count = "${var.vms_count}"

  connection {
    host      = "${join("", module.lb.out-pip_fqdn)}"
    user      = "${var.uname}"
    password  = "${var.upass}"
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
