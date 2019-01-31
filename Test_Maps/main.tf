#Create ASGs for each tier
resource "azurerm_application_security_group" "App-ASG" {
  count = "${length(var.App_Subnets)}" 
  name                = "${format("%s-%s-%s", "ASG", "${element(var.App_Subnets, count.index)}","${var.App_Name}")}"
  location            = "${var.region}"
  resource_group_name = "${var.RG_Name}"
}


data "azurerm_application_security_group" "test" {
  count = "${length(var.Web_rules)}"
  name = "${lookup(var.Web_rules[count.index], "destination_application_security_group_ids", "")}"
  #name                = "${format("%s-%s", "ASG", "${element(var.HUB_Subnets_Name, 0)}")}"
  resource_group_name = "${var.RG_Name}"
}
output "ASG_ID" {
  value = "${data.azurerm_application_security_group.test.*.id}"
}

output "ASG_NAME" {
  value = "${lookup(var.Web_rules[0], "destination_application_security_group_ids", "")}"
}
