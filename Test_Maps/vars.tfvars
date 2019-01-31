App_Name = "App01"
App_Subnets = ["Web","App","DB"]
HUB_Subnets_Name = ["AzureFirewallSubnet","VMSubnet"]

Web_rules = [{
  name                   = "AllowInboundTCP22"
  priority               = "1001"
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_application_security_group_ids = "ASG-VMSubnet"
  destination_application_security_group_ids  = "ASG-Web-App01"
  #destination_application_security_group_ids  = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 0)}","${var.App_Name}")}"
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
  destination_application_security_group_ids  = "ASG-App-App01"
  #destination_application_security_group_ids  = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, 1)}","${var.App_Name}")}"
  source_port_range      = "*"
  destination_port_range = "22"
  description            = "Allow TCP 22 from Web subnet to App subnet"
  }
  ]

