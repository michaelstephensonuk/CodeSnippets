
# Resource group where the service bus is located
data "azurerm_resource_group" "servicebus" {
  name     = var.servicebus_resource_group
}

# The service bus namespace
data "azurerm_servicebus_namespace" "servicebus" {
  name                = var.servicebus_name
  resource_group_name = data.azurerm_resource_group.servicebus.name
}

