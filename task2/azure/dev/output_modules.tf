
output "out-lb-ipaddres" {
  value = "URL: http://${join(", ", module.lb.out-pip_ips)}"
}
output "out-lb-fqdn" {
  value = "URL: http://${join(", ", module.lb.out-pip_fqdn)}"
}
output "out-vms-nic" {
  value = "${module.vms.out-nic_ids}"
}
