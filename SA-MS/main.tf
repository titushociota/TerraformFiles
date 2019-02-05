data "azurerm_subnet" "subnet1" {
  name                 = "${var.Subnet_Name}"
  virtual_network_name = "${var.Vnet_Name}"
  resource_group_name  = "${var.RG_Name}"
}

resource "azurerm_storage_account" "testsa" {
  name                = "storageaccountname"
  resource_group_name = "${var.RG_Name}"

  location                 = "${var.region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    ip_rules                   = ["127.0.0.1"]
    virtual_network_subnet_ids = ["${data.azurerm_subnet.subnet1.id}"]
  }

  tags {
    environment = "staging"
  }
}