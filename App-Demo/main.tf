# Configure the Microsoft Azure Provider

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${format("%s-%s", "${var.RG_Name}", "${var.App_Name}")}"
    location = "${var.region}"

    tags {
        environment = "Terraform threeTiersDemo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "SpokeVNET" {
    count = "${var.Create_Spoke_Vnet}"
    name                = "${var.Vnet_Spoke_Name}"
    address_space       = "${var.Vnet_Spoke_Address_Space}"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}
resource "azurerm_virtual_network" "HUBVNET" {
    count = "${var.Create_HUB_Vnet}"
    name                = "${var.Vnet_HUB_Name}"
    address_space       = "${var.Vnet_HUB_Address_Space}"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}
# Create the default Network Security Group for Deny all
resource "azurerm_network_security_group" "myterraformnsg" {
    count = "${length(var.App_Subnets)}"
    name                = "${format("%s-%s-%s", "NSG", "${element(var.VM_Name, count.index)}","${var.App_Name}")}"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    security_rule {
        name                       = "DenyAllInbound"
        priority                   = 2001
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "DenyAllOutbound"
        priority                   = 2001
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}


# Create App subnets
resource "azurerm_subnet" "App01_Subnets" {
    count = "${length(var.App_Subnets)}"
    name  = "${format("%s-%s-%s", "SNET", "${element(var.App_Subnets, count.index)}","${var.App_Name}")}"
    resource_group_name  = "${var.Infra-RG}"
    virtual_network_name = "${var.Vnet_Spoke_Name}"
    address_prefix = "${element(var.App_Subnets_prefix, count.index)}"
}


#Add the NSG to the spoke subnets
resource "azurerm_subnet_network_security_group_association" "testNSG" {
  count = "${length(var.App_Subnets)}"
   subnet_id                 = "${element(azurerm_subnet.App01_Subnets.*.id, count.index)}"
   network_security_group_id = "${element(azurerm_network_security_group.myterraformnsg.*.id, count.index)}"
}




#Create ASGs for each tier
resource "azurerm_application_security_group" "App-ASG" {
  count = "${length(var.App_Subnets)}" 
  name                = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, count.index)}","${var.App_Name}")}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
}

# Create private network interface
resource "azurerm_network_interface" "privatenic" {
    count = "${length(var.App_Subnets)}"
    name                      = "${format("%s-%s-%s", "NIC", "${element(var.App_Subnets, count.index)}","${var.App_Name}")}"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "${format("%s-%s-%s", "NicConfiguration", "${element(var.App_Subnets, count.index)}","${var.App_Name}")}"
        subnet_id                     = "${element(azurerm_subnet.App01_Subnets.*.id, count.index)}"
        private_ip_address_allocation = "dynamic"
        application_security_group_ids = ["${element(azurerm_application_security_group.App-ASG.*.id, count.index)}"]
    }

    tags {
        environment = "Terraform Demo"
    }
}


# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "${var.region}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "privatevm" {
    count = "${length(var.VM_Name)}"
    name                  = "${element(var.VM_Name, count.index)}"
    location              = "${var.region}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.privatenic.*.id, count.index)}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "${format("%s-%s", "OsDisk", "${element(var.VM_Name, count.index)}")}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${element(var.VM_Name, count.index)}"
        admin_username = "azureuser"
        admin_password = "${var.Linux_Pass}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }    
    #    ssh_keys {
    #        path     = "/home/azureuser/.ssh/authorized_keys"
    #        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO3PfxToO5tptMtyPZ3JIVNL6bNPriYIdcxPnLcgiy3/dC9f8mYD927GIfgCiE7Knh52VBCKFcqdyPxKhwukFTNdTU5kdEbw+PiErmVeQg91SFW3hSwKAdiz6CRO0h4OHzyiZyqq0BgyQGg6rC5d/qMjh7z7GUIES8egXj4VIw2kii9hxV38v8MXEgnT5axxBy/8rkbGaDHlDDUdV5x10RZfmIkGVxyYk8bs6HtDFOP0wL5xYh1+8Vxg7E4bmX8bCVz9bg7jjteEQp2nkUCSqk1A1W/Me7jOj5F/hAK/yQ9R7mENLaYM38LC5aCszkgegjvQaUXQntdX04PqpT5ZP5 titus@cc-31fac8fa-5fb97c7956-z2dhj"
    #    }
    #}

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

#Define Web Route to HUB VNET
resource "azurerm_route_table" "WEBRoute" {
  name                          = "WEbDefaultRoute"
  location                      = "${var.region}"
  resource_group_name           = "${azurerm_resource_group.myterraformgroup.name}"
  disable_bgp_route_propagation = false

  route {
    name           = "defaultroute"
    address_prefix = "10.0.0.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4"
  }

  tags {
    environment = "WEB Route"
  }
}

#Associate the UDR to WEB subnet
resource "azurerm_subnet_route_table_association" "AddWebRoute" {
   count = "${length(var.App_Subnets)}"  
  subnet_id      = "${element(azurerm_subnet.App01_Subnets.*.id , count.index)}"
  route_table_id = "${azurerm_route_table.WEBRoute.id}"
}

# Add the rules for each tier based on the ASGs
resource "azurerm_network_security_rule" "Web-rules" {
  count                       = "${length(var.Web_rules)}"
  name                        = "${lookup(var.Web_rules[count.index], "name")}"
  priority                    = "${lookup(var.Web_rules[count.index], "priority")}"
  direction                   = "${lookup(var.Web_rules[count.index], "direction", "Any")}"
  access                      = "${lookup(var.Web_rules[count.index], "access", "Allow")}"
  protocol                    = "${lookup(var.Web_rules[count.index], "protocol", "*")}"
  source_port_range           = "${lookup(var.Web_rules[count.index], "source_port_ranges", "*")}"
  destination_port_range      = "${lookup(var.Web_rules[count.index], "destination_port_ranges", "*")}"
  source_address_prefix       = "${lookup(var.Web_rules[count.index], "source_address_prefix", "*")}"
  destination_application_security_group_ids  = ["${azurerm_application_security_group.App-ASG.0.id}"]
  description                 = "${lookup(var.Web_rules[count.index], "description")}"
  resource_group_name         ="${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_name = "${element(azurerm_network_security_group.myterraformnsg.*.name, 0)}"
}
resource "azurerm_network_security_rule" "App-rules" {
  count                       = "${length(var.App_rules)}"
  name                        = "${lookup(var.App_rules[count.index], "name")}"
  priority                    = "${lookup(var.App_rules[count.index], "priority")}"
  direction                   = "${lookup(var.App_rules[count.index], "direction", "Any")}"
  access                      = "${lookup(var.App_rules[count.index], "access", "Allow")}"
  protocol                    = "${lookup(var.App_rules[count.index], "protocol", "*")}"
  source_port_range           = "${lookup(var.App_rules[count.index], "source_port_ranges", "*")}"
  destination_port_range      = "${lookup(var.App_rules[count.index], "destination_port_ranges", "*")}"
  source_application_security_group_ids       = ["${azurerm_application_security_group.""${ASG_name}"".0.id}"]
  #source_application_security_group_ids       = ["${azurerm_application_security_group.App-ASG.0.id}"]
  destination_application_security_group_ids  = ["${azurerm_application_security_group.App-ASG.1.id}"]
  description                 = "${lookup(var.App_rules[count.index], "description")}"
  resource_group_name         ="${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_name = "${element(azurerm_network_security_group.myterraformnsg.*.name, 1)}"
}
resource "azurerm_network_security_rule" "DB-rules" {
  count                       = "${length(var.DB_rules)}"
  name                        = "${lookup(var.DB_rules[count.index], "name")}"
  priority                    = "${lookup(var.DB_rules[count.index], "priority")}"
  direction                   = "${lookup(var.DB_rules[count.index], "direction", "Any")}"
  access                      = "${lookup(var.DB_rules[count.index], "access", "Allow")}"
  protocol                    = "${lookup(var.DB_rules[count.index], "protocol", "*")}"
  source_port_range           = "${lookup(var.DB_rules[count.index], "source_port_ranges", "*")}"
  destination_port_range      = "${lookup(var.DB_rules[count.index], "destination_port_ranges", "*")}"
  source_application_security_group_ids       = ["${azurerm_application_security_group.App-ASG.1.id}"]
  destination_application_security_group_ids  = ["${azurerm_application_security_group.App-ASG.2.id}"]
  description                 = "${lookup(var.DB_rules[count.index], "description")}"
  resource_group_name         ="${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_name = "${element(azurerm_network_security_group.myterraformnsg.*.name, 2)}"
}