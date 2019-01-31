variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}

variable "Linux_Pass" {}

#region definition
variable "region" {
  default = "eastus"
}
variable "App_Name" {
  description = "Application name"
}

variable "Infra-RG" {
  
}

#Resource group definition
#*********************************************************
variable "RG_Name" {
}
#*********************************************************


#Hub Vnet Definition
#*********************************************************
variable "Create_HUB_Vnet" {
  description = "if true the spoke Vnet will be created, for false the Vnet creation will be skipped"
}
variable "Vnet_HUB_Name" {
  description = "The name of the spoke Vnet"
}
variable "Vnet_HUB_Address_Space" {
  description = "IP Address space for spoke Vnet"
  type = "list"
}
#*********************************************************


#HUB Subnets Definition
#*********************************************************
variable "HUB_Subnets_Name" {
  description= "list the names of the subnets in the HUB VNET"
  type = "list"
}
variable "HUB_Subnets_Address_Prefix" {
  description = "list with HUB subnets IP addresses"
  type = "list"
}
#*********************************************************

#Spoke Vnet definition
#*********************************************************
variable "Create_Spoke_Vnet" {
  description = "if true the spoke Vnet will be created, for false the Vnet creation will be skipped"
}
variable "Vnet_Spoke_Name" {
  description = "The name of the spoke Vnet"
}
variable "Vnet_Spoke_Address_Space" {
  description = "IP Address space for spoke Vnet"
  type = "list"
}
#*********************************************************

#Spoke VNet subnets definition
#*********************************************************
variable "App_Subnets" {
  description = "the subnets associated with the application"
  type = "list"
}
variable "App_Subnets_prefix" {
  description = " the prefixies associated with each subnet"
  type = "list"
}
#*********************************************************


#NSGs definition
variable "NSG_name" {
  description = "name of the NSGs"
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

variable "App_rules" {
  description = "Custom set of security rules using this format for App tier"
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
variable "DB_rules" {
  description = "Custom set of security rules using this format for DB tier"
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

#VMs definitions
variable "VM_Name" {
  description = " The name of the VMs part of the three Tier App"
  type = "list"
  default = ["Web-App01","App-App01","DB-App01"]
}