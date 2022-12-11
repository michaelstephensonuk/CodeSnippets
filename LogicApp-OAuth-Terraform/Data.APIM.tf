


data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = data.azurerm_resource_group.apim_resource_group.name
}