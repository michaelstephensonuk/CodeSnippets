data "local_file" "logicapp_demo1_definition" {
  filename = "Res.LogicApp.Demo-LogicApp-1.json"
}

data "template_file" "logicapp_demo1_definition" {
    template = data.local_file.logicapp_demo1_definition.content
    vars = merge(
                tomap({
                    "apimResourceGroupName"     = data.azurerm_api_management.apim_instance.resource_group_name
                    "apimInstanceName"          = data.azurerm_api_management.apim_instance.name      
                    "helperFunctionAppsName"    = data.azurerm_windows_function_app.helper_functions.name
                    "functionsResourceGroupName" = data.azurerm_windows_function_app.helper_functions.resource_group_name
                }), 
                local.logicapp_common_replace_tokens)                
}

resource "azapi_resource" "logicapp_demo1" {
    type                = "Microsoft.Logic/workflows@2019-05-01"
    name                = "Demo-LogicApp-1"

    location            = azurerm_resource_group.logicapps.location
    parent_id           = azurerm_resource_group.logicapps.id

    depends_on = [

        //The logic app definition will depend on logic app 2 being deployed first
        //we will add an explicit dependency here to enforce that
        azapi_resource.logicapp_demo2,

        #The logic app also uses the helper function in the function app
        azurerm_function_app_function.echo_helper_function,

        #The logic app also uses the apim operation for echoing the token
        azurerm_api_management_api_operation.logicapp_helper_echo_token
    ]
    
    identity {
        type  = "UserAssigned"
        identity_ids = [ azurerm_user_assigned_identity.logicapps.id ]
    }

    tags = merge(
                tomap({
                    #Note this forces the logic app to be updated every time we run deploy
                    "DeploymentTime" = timestamp(),
                }), 
                local.logicapp_default_tags)

    body = jsonencode({
        properties = {
            definition = jsondecode(data.template_file.logicapp_demo1_definition.rendered)            
            parameters = {
                "queue_name" = {
                    value = azurerm_servicebus_queue.demo_logicap_1.name
                    type         = "String"
                }              
                "$connections" = {
                    value = {
                        sql_1 = {
                            connectionId = azapi_resource.connectors_sql.id
                            connectionName = azapi_resource.connectors_sql.name
                            id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/northeurope/managedApis/sql"
                        }
                        servicebus = {
                            connectionId = azapi_resource.connectors_servicebus.id
                            connectionName = azapi_resource.connectors_servicebus.name
                            id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/northeurope/managedApis/servicebus"
                        }
                    }
                }                
            }
        }
    })
}
