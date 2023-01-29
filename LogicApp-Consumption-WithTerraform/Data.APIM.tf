
# Resource group the APIM belongs to
data "azurerm_resource_group" "apim_resource_group" {
  name     = var.apim_resource_group
}


# APIM instance we will add the API to
data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = data.azurerm_resource_group.apim_resource_group.name
}

data "azurerm_api_management_api" "logicapp_helper_api" {
  name                = "utility-logicapp-helpers"
  api_management_name = data.azurerm_api_management.apim_instance.name
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  revision            = "1"
}

