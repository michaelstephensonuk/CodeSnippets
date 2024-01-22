

#Map of the logic app consumption workflows we want to expose as API's
locals{
    logicapp_consumption_list = [
        {
            logicapp_name = "Demo-LogicApp-1"
            resource_group_name = var.logicapp_consumption_resource_group
        },
        
    ]
}


#Create the operations for each logic app consumption workflow
module "logicapp_consumption_apis" {
    source = "./Modules/LogicApp/Consumption/CreateAPIOperation"

    count                           = length(local.logicapp_consumption_list)
    
    logicapp_name                   = local.logicapp_consumption_list[count.index].logicapp_name
    logicapp_resource_group_name    = local.logicapp_consumption_list[count.index].resource_group_name

    apim_resource_group_name        = azurerm_api_management_api.my_api.resource_group_name
    apim_name                       = azurerm_api_management_api.my_api.api_management_name
    apim_api_name                   = azurerm_api_management_api.my_api.name

    providers = {
      azurerm = azurerm,
      azapi = azapi
    }
}
