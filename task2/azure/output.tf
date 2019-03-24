output "domain_name_label" {
//  value = "${azurerm_public_ip.task2.*.fqdn}"
  value = ["${azurerm_public_ip.main-ip.*.domain_name_label}"]
}

output "fqdn" {
//  value = "${azurerm_public_ip.task2.*.fqdn}"
  value = ["${azurerm_public_ip.main-ip.*.fqdn}"]
}

output "public_ip_address" {
  //value = ["${azurerm_public_ip.main-ip.*.ip_address}"]
  value = ["${data.azurerm_public_ip.main-data-ip.*.ip_address}"]

  //value = "${azurerm_public_ip.task2.*.ip_address}"
}

output "URLs IP" {
  value = "${formatlist("http://%v", azurerm_public_ip.main-ip.*.fqdn)}"
}
