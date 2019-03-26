output "out-pip_ids" {
  value = ["${azurerm_public_ip.mod_pip.*.ip_address}"]
}
output "out-nic_ids" {
  value = ["${azurerm_network_interface.mod_nic.*.id}"]
}
output "out-vm_ids" {
  value = ["${azurerm_virtual_machine.mod-vms.*.id}"]
}
output "out-rg-name" {
  value = "${local.rg-name}"
}
