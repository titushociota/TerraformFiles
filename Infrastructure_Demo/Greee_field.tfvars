

NSG_name = ["AllowTCP22"]
App_Name = "App01"

Create_HUB_Vnet = true
Vnet_HUB_Address_Space = ["10.0.0.0/24"]
Vnet_HUB_Name = "HubVNET"
HUB_Subnets_Name = ["AzureFirewallSubnet","VMSubnet"]
HUB_Subnets_Address_Prefix = ["10.0.0.0/26","10.0.0.64/26"]

Create_Spoke_Vnet = true
Vnet_Spoke_Address_Space = ["10.0.1.0/24"]
Vnet_Spoke_Name = "SpokeVNET"

VM_Name =["Test-VM"]