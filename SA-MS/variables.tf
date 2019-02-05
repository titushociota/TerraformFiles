variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}
variable "region" {
  default = "eastus"
}
variable "RG_Name" {
  default = "NetworkWatcherRG"
}
variable "Vnet_Name" {
  description = "The name of the Vnet"
  default = "NetworkWatcherRG-vnet"
}
variable "Subnet_Name" {
  description = "Name of the subnet"
  default = "default"
}
