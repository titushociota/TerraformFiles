

NSG_name = ["AllowTCP22"]
Infra-RG = "RG-Demo-Infrastructure"
App_Name = "App01"
RG_Name = "RG-Demo"

Create_HUB_Vnet = false
Vnet_HUB_Address_Space = ["10.0.0.0/24"]
Vnet_HUB_Name = "HubVNET"
HUB_Subnets_Name = ["AzureFirewallSubnet"]
HUB_Subnets_Address_Prefix = ["10.0.0.0/26"]

Create_Spoke_Vnet = false
Vnet_Spoke_Address_Space = ["10.0.1.0/24"]
Vnet_Spoke_Name = "SpokeVNET"

App_Subnets = ["Web","App","DB"]
App_Subnets_prefix = ["10.0.1.0/28","10.0.1.16/28","10.0.1.32/28"]


Web_rules = [{
  name                   = "AllowInboundTCP22"
  priority               = "1001"
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_application_security_group_ids = "ASG-VMSubnet"
  destination_application_security_group_ids  = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 0)}","${var.App_Name}")}"
  source_port_range      = "*"
  destination_port_range = "22"
  description            = "Allow TCP 22 from Test VM to Web subnet"
  },
  {
  name                   = "AllowOutboundTCP22"
  priority               = "1001"
  direction              = "Outbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_application_security_group_ids = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 0)}","${var.App_Name}")}"
  destination_application_security_group_ids  = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 1)}","${var.App_Name}")}"
  source_port_range      = "*"
  destination_port_range = "22"
  description            = "Allow TCP 22 from Web subnet to App subnet"
  }
  ]

App_rules = [{
  name                   = "AllowInboundTCP22"
  priority               = "1001"
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  source_application_security_group_ids = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 0)}","${var.App_Name}")}"
  destination_application_security_group_ids  = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 1)}","${var.App_Name}")}"
  destination_port_range = "22"
  description            = "Allow TCP 22 from ASG Web only"
  },
  {
  name                   = "AllowOutboundTCP22"
  priority               = "1001"
  direction              = "Outbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  source_application_security_group_ids = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 1)}","${var.App_Name}")}"
  destination_application_security_group_ids  = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 2)}","${var.App_Name}")}"
  destination_port_range = "22"
  description            = "Allow TCP 22 from App subnet to DB subnet"
  }
  ]
  
  DB_rules = [{
  name                   = "AllowInboundTCP22"
  priority               = "1001"
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  source_application_security_group_ids = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 1)}","${var.App_Name}")}"
  destination_application_security_group_ids  = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 2)}","${var.App_Name}")}"
  destination_port_range = "22"
  description            = "Allow TCP 22 from ASG App only"
  }
  ]