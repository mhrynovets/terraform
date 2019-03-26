output "out-subnet-ids" {
  value = ["${azurerm_subnet.mod-subnet.*.id}"]
}
output "out-vnet-name" {
  value = ["${local.vnet-name}"]
}
output "out-rg-name" {
  value = "${local.rg-name}"
}
