
output "Private_IPs" {
    value = "${azurerm_network_interface.privatenic.*.private_ip_address}"
}

output "SubnetList" {
    value = "${azurerm_subnet.App01_Subnets.*.name}"
}
