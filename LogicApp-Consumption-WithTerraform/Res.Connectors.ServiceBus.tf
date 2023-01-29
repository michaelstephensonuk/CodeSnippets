
locals {
  # Common tags to be assigned to all resources
  connectors_servicebus = {
      name = "APIC-ServiceBus"    
  }  
}

resource "azapi_resource" "connectors_servicebus" {
    type                = "Microsoft.Web/connections@2016-06-01"
    name                = local.connectors_servicebus.name
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
            displayName = local.connectors_servicebus.name
            api = {                
                id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/northeurope/managedApis/servicebus"
                type = "Microsoft.Web/locations/managedApis"
            },
            parameterValues = {
                connectionString = azurerm_servicebus_queue_authorization_rule.demo_logicap_1.primary_connection_string
            }            
        }    
    })
}