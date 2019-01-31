output "FW_Public_Ip" {
    description = " this variable will hold the FW public IP"
    value = "${azurerm_public_ip.FWpip.*.ip_address}"
}

#output "FW_Private_IP" {    
#   value = "${azurerm_firewall.FW_Perimeter.PrivateIPAddress[0]}"
#}
output "Private_IPs" {
    value = "${azurerm_network_interface.privatenic.*.private_ip_address}"
}

output "HUB-SubnetList" {
    value = "${azurerm_subnet.HUB_Subnets.*.name}"
}


