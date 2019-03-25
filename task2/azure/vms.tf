
resource "azurerm_virtual_machine" "main-vms" {
  count                 = "${var.vms_count}"
  name                  = "${var.prefix}-vms-${count.index}"
  location              = "${azurerm_resource_group.main-rg.location}"
  resource_group_name   = "${azurerm_resource_group.main-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.main-nic.*.id, count.index)}"]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk-vm-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    //computer_name  = "${var.prefix}-vm-${count.index}"
    computer_name  = "${element(azurerm_public_ip.main-ip.*.domain_name_label, count.index)}"
    admin_username = "devops"
    //admin_password = "Password1237!"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [{
      path     = "/home/devops/.ssh/authorized_keys"
      key_data = "${tls_private_key.main-tls.public_key_openssh}"
    }]
  }

  connection {
      user = "devops"
      private_key = "${tls_private_key.main-tls.private_key_pem}"
      //host = "${element(azurerm_public_ip.main-ip.*.domain_name_label, count.index)}"
      //host = "${element(azurerm_public_ip.main-ip.*.ip_address, count.index)}"
      //host = "${element(azurerm_public_ip.main-ip.*.fqdn, count.index)}"
      //host = "${element(data.azurerm_public_ip.main-data-ip.*.ip_address, count.index)}"
      //type = "ssh"
      //timeout = "2m"
      //agent = true
  }

  provisioner "file" {
    source      = "files/initweb.sh"
    destination = "/tmp/initweb.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/initweb.sh",
      "/tmp/initweb.sh",
    ]
  }

  tags = "${merge(
    local.common_tags,
    map(
      "custom-vm", "${var.prefix}-vm"
    )
  )}"
}
