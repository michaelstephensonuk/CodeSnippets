data "azurerm_resource_group" "functions_resource_group" {
  name     = var.functions_resource_group
}

data "azurerm_windows_function_app" "helper_functions" {
  name                = var.functions_name
  resource_group_name = data.azurerm_resource_group.functions_resource_group.name
}