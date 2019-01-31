variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}

variable "Linux_Pass" {}

variable "RG_Name" {
  default = "NetworkWatcherRG"
}

variable "region" {
  default = "eastus"
}
variable "App_Name" {
  description = "Application name"
}
variable "HUB_Subnets_Name" {
  description= "list the names of the subnets in the HUB VNET"
  type = "list"
}
variable "App_Subnets" {
  description = "the subnets associated with the application"
  type = "list"
}

#NSG rules for each tier
variable "Web_rules" {
  description = "Custom set of security rules using this format for Web tier"
  type        = "list"
  default     = []

  # Example:
  # custom_rules = [{
  # name                   = "myssh"
  # priority               = "101"
  # direction              = "Inbound"
  # access                 = "Allow"
  # protocol               = "tcp"
  # source_port_range      = "1234"
  # destination_port_range = "22"
  # description            = "description-myssh"
  #}]
}
