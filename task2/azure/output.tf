
output "public_ip_address" {
  value = ["${data.azurerm_public_ip.main-data-ip.*.ip_address}"]
}

output "VM URLs" {
  value = "${formatlist("http://%v", azurerm_public_ip.main-ip.*.fqdn)}"
}

output "LoadBalancer connection data" {
  value = [
    "LoadBalancer URL: http://${join(" ", azurerm_public_ip.lbpip.*.fqdn)}",
    "LoadBalancer IP: http://${join("", azurerm_public_ip.lbpip.*.ip_address)}"
  ]
}
