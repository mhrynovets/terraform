output "out-pip_ips" {
  value = ["${azurerm_public_ip.lbpip.*.ip_address}"]
}
output "out-pip_fqdn" {
  value = ["${azurerm_public_ip.lbpip.*.fqdn}"]
}
