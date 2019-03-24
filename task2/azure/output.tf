output "domain_name_label" {
  value = ["${azurerm_public_ip.main-ip.*.domain_name_label}"]
}

output "public_ip_address" {
  value = ["${data.azurerm_public_ip.main-data-ip.*.ip_address}"]
}

output "URLs" {
  value = "${formatlist("http://%v", azurerm_public_ip.main-ip.*.fqdn)}"
}
