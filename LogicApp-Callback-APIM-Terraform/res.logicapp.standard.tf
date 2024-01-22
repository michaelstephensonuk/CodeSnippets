
#Map of the logic app standard workflows we want to expose as API's
locals{
    logicapp_standard_list = [
        {
            resource_group_name     = var.logicapp_standard_resource_group
            logic_app_name          = var.logicapp_standard_app_name
            workflow_name           = "Stateful1"
            workflow_trigger_name   = "When_a_HTTP_request_is_received"
        }
    ]
}

#Create the operations for each logic app consumption workflow
module "logicapp_standard_apis" {
    source = "./Modules/LogicApp/Standard/CreateAPIOperation"

    count                           = length(local.logicapp_standard_list)
    
    logicapp_name                   = local.logicapp_standard_list[count.index].logic_app_name
    logicapp_resource_group_name    = local.logicapp_standard_list[count.index].resource_group_name
    workflow_name                   = local.logicapp_standard_list[count.index].workflow_name
    workflow_trigger_name           = local.logicapp_standard_list[count.index].workflow_trigger_name

    apim_resource_group_name        = azurerm_api_management_api.my_api.resource_group_name
    apim_name                       = azurerm_api_management_api.my_api.api_management_name
    apim_api_name                   = azurerm_api_management_api.my_api.name

    providers = {
      azurerm = azurerm,
      azapi = azapi
    }
}