# Configure the Microsoft Azure Provider

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.RG_Name}"
    location = "${var.region}"

    tags {
        environment = "Terraform Tree-Tire App Demo"
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

# Create HUB subnets
resource "azurerm_subnet" "HUB_Subnets" {
    count = "${var.Create_HUB_Vnet ? length(var.HUB_Subnets_Name) : 0}"
    name  = "${element(var.HUB_Subnets_Name, count.index)}"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.HUBVNET.name}"
    address_prefix = "${element(var.HUB_Subnets_Address_Prefix, count.index)}"
}

#Create ASGs for Hub VNET subnets
resource "azurerm_application_security_group" "HUB-ASG" {
  count = "${length(var.HUB_Subnets_Name)}" 
  name                = "${format("%s-%s", "ASG", "${element(var.HUB_Subnets_Name, count.index)}")}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "${format("%s-%s", "PublicIP", "${element(var.VM_Name, 1)}")}"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Test VM Public IP"
    }
}
resource "azurerm_public_ip" "FWpip" {
    name                         = "FWpip"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "static"
    sku                          = "Standard"

    tags {
        environment = "Firewall public IP"
    }
}
#Firewall perimeter
resource "azurerm_firewall" "FW_Perimeter" {
  name                = "FW-Perimeter"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = "${element(azurerm_subnet.HUB_Subnets.*.id, 0)}"
    internal_public_ip_address_id = "${azurerm_public_ip.FWpip.id}"
  }
}

# Create private network interface
resource "azurerm_network_interface" "privatenic" {
    count = "${length(var.VM_Name)}"
    name                      = "${format("%s-%s", "Nic", "${element(var.VM_Name, count.index)}")}"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "${format("%s-%s", "NicConfiguration", "${element(var.VM_Name, count.index)}")}"
        subnet_id                     = "${element(azurerm_subnet.HUB_Subnets.*.id, count.index + 1)}"
        private_ip_address_allocation = "dynamic"
        application_security_group_ids = ["${element(azurerm_application_security_group.HUB-ASG.*.id, 1)}"]
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Create public network interface
resource "azurerm_network_interface" "publicnic" {
    count = "${length(var.VM_Name)}"
    name                      = "${format("%s-%s", "Nic", "${element(var.VM_Name, count.index)}")}"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "${format("%s-%s", "NicConfiguration", "${element(var.VM_Name, count.index)}")}"
        subnet_id                     = "${element(azurerm_subnet.HUB_Subnets.*.id, count.index + 1)}"
        private_ip_address_allocation = "dynamic"
     #   public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
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
    count = 1
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

resource "azurerm_virtual_machine" "publicvm" {
    count = "${length(var.VM_Name)}"
    name                  = "${element(var.VM_Name, count.index)}"
    location              = "${var.region}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.publicnic.*.id, count.index)}"]
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

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

#Define Route to Spoke VNET
resource "azurerm_route_table" "SpokeRoute" {
  name                          = "SpokeRoute"
  location                      = "${var.region}"
  resource_group_name           = "${azurerm_resource_group.myterraformgroup.name}"
  disable_bgp_route_propagation = false

  route {
    name           = "routetoSpoke"
    address_prefix = "10.0.1.0/24"
    next_hop_type  = "VirtualAppliance"
    #find out how to get the Firewall private IP
    next_hop_in_ip_address = "10.0.0.4"
  }

  tags {
    environment = "Spoke Route"
  }
}

#Associate the UDR to HUB VM subnet
resource "azurerm_subnet_route_table_association" "AddWebRoute" {
  subnet_id      = "${element(azurerm_subnet.HUB_Subnets.*.id, 1)}"
  route_table_id = "${azurerm_route_table.SpokeRoute.id}"
}

#Create VNET peering between HUB and Spoke
resource "azurerm_virtual_network_peering" "peer1" {
    count = "${var.Create_HUB_Vnet}"
    name                         = "HuB-to-Spoke"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name         = "${azurerm_virtual_network.HUBVNET.name}"
    remote_virtual_network_id    = "${azurerm_virtual_network.SpokeVNET.id}"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    use_remote_gateways          = false
    depends_on = ["azurerm_virtual_network.HUBVNET","azurerm_virtual_network.SpokeVNET"]
}
resource "azurerm_virtual_network_peering" "peer2" {
    count = "${var.Create_HUB_Vnet}"
    name                         = "Spoke-to-HUB"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name         = "${azurerm_virtual_network.SpokeVNET.name}"
    remote_virtual_network_id    = "${azurerm_virtual_network.HUBVNET.id}"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
    depends_on = ["azurerm_virtual_network.HUBVNET","azurerm_virtual_network.SpokeVNET"]
}
