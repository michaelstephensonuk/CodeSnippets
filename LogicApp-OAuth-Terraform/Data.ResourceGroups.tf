#Resource Group
#Description: This will allow us to reference the main EAI resource group
#========================================================================
data "azurerm_resource_group" "apim_resource_group" {
  name     = var.apim_resource_group
}


