
locals {
  # Common tags to be assigned to all resources
  connectors_sql = {
      name = "APIC-SQL"    
  }  
}

resource "azapi_resource" "connectors_sql" {
    type                = "Microsoft.Web/connections@2016-06-01"
    name                = local.connectors_sql.name
    location            = azurerm_resource_group.logicapps.location
    parent_id           = azurerm_resource_group.logicapps.id
  
    tags = merge(
                tomap({
                    #Note this forces the logic app to be updated every time we run deploy
                    "DeploymentTime" = timestamp(),
                }), 
                local.logicapp_default_tags)

    body = jsonencode({
        properties = {      
            displayName = local.connectors_sql.name
            api = {                
                id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/northeurope/managedApis/sql"
                type = "Microsoft.Web/locations/managedApis"
            },
            parameterValues = {
                authType = "sqlAuthentication"
                server = data.azurerm_key_vault_secret.synapse_server.value,
                database = data.azurerm_key_vault_secret.synapse_database.value
                username = data.azurerm_key_vault_secret.synapse_username.value
                password = data.azurerm_key_vault_secret.synapse_password.value
            }            
        }    
    })
}