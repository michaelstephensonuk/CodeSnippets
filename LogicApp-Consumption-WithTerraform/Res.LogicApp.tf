locals {
  # Common tags to be assigned to all resources
  logicapp_default_tags = {
      Owner = "EAI"    
  }

  logicapp_common_replace_tokens = {
      "logicAppResourceGroupName"   = azurerm_resource_group.logicapps.name
      "subscription_id" = data.azurerm_client_config.current.subscription_id        
  }
}


# Create a resource group for the logic app
resource "azurerm_resource_group" "logicapps" {
    name     = "Blog_LogicApp_Consumption_Terraform"
    location = data.azurerm_resource_group.apim_resource_group.location
}

# Create a user assigned managed identity which we will assign to the logic app
resource "azurerm_user_assigned_identity" "logicapps" {
    name                = "logic-app-terraform"

    location            = azurerm_resource_group.logicapps.location  
    resource_group_name = azurerm_resource_group.logicapps.name
}








