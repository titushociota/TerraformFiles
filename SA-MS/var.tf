variable "region" {
  default = "eastus"
}

variable "RG_Name" {
  default = "NetworkWatcherRG"
}

variable "Vnet_Name" {
  description = "The name of the Vnet"
  default = "testVNET"
}

variable "Subnet_Name" {
  description = "Name of the subnet"
  default = "TestSubnet"
}
