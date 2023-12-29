
#Resource Group
#Description: This will allow us to reference the main EAI resource group
#========================================================================
data "azurerm_resource_group" "ais_resource_group" {
  name     = var.main_resource_group
}