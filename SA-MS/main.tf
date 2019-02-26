/*data "azurerm_subnet" "subnet1" {
  name                 = "${var.Subnet_Name}"
  virtual_network_name = "${var.Vnet_Name}"
  resource_group_name  = "${var.RG_Name}"
}
*/
resource "azurerm_storage_account" "testsa" {
  name                = "satitusbackendterraform"
  resource_group_name = "${var.RG_Name}"

  location                 = "${var.region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    ip_rules                   = ["99.240.132.84"]
    #virtual_network_subnet_ids = ["${data.azurerm_subnet.subnet1.id}"]
  }

  tags {
    environment = "MSDN"
    description = "My terraform State storage"
  }
}