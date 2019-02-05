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

***#Resource group definition
#*********************************************************
variable "RG_Name" {
  default = "RG-Demo-Infrastructure"
}
#******************************************************


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



#VMs definitions
variable "VM_Name" {
  description = " The name of the VMs that will be deploy in HUB VNET for testing purposes"
  type = "list"
  
}