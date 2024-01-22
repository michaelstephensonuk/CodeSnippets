

//Read APIM Resource Group
data "azurerm_resource_group" "apim_resource_group" {
  name = var.apim_resource_group_name
}

//Read the Logic App
data "azurerm_logic_app_standard" "logicapp_site" {
  name                = var.logicapp_name
  resource_group_name = var.logicapp_resource_group_name
}


//Read the workflow object
data "azapi_resource" "workflow" {
  type                      = "Microsoft.Web/sites/workflows@2022-09-01"
  name                      = var.workflow_name
  parent_id                 = data.azurerm_logic_app_standard.logicapp_site.id
  response_export_values    = ["*"]
}

//Read the trigger object
data "azapi_resource" "workflow_trigger" {
  type                      = "Microsoft.Web/sites/hostruntime/webhooks/api/workflows/triggers@2022-09-01"
  name                      = var.workflow_trigger_name
  parent_id                 = "${data.azurerm_logic_app_standard.logicapp_site.id}/hostruntime/runtime/webhooks/workflow/api/management/workflows/${var.workflow_name}"
  response_export_values    = ["*"]
}

//Read the call back url for the trigger
data "azapi_resource_action" "workflow_trigger_callback" {
  type                   = "Microsoft.Web/sites/hostruntime/webhooks/api/workflows/triggers@2022-09-01"
  resource_id            = data.azapi_resource.workflow_trigger.id
  action                 = "listCallbackurl"
  response_export_values = ["*"]

}

resource "azurerm_api_management_backend" "workflow_backend" {
    name                = "${data.azurerm_logic_app_standard.logicapp_site.name}-${data.azapi_resource.workflow.name}"
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = var.apim_name
    protocol            = "http"
    url                 = jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).basePath

    credentials {
        query = {
            "api-version"   = jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.api-version
            "sig"           = jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.sig
            "sp"            = jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.sp
            "sv"            = jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.sv
        }
  }
}

#Manage the operation within the API for this logic app
resource "azurerm_api_management_api_operation" "api_operation" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = var.apim_name
    
    operation_id        = "${data.azurerm_logic_app_standard.logicapp_site.name}-${data.azapi_resource.workflow.name}-post"

    api_name            = var.apim_api_name  

    display_name        = "${data.azurerm_logic_app_standard.logicapp_site.name} - ${data.azapi_resource.workflow.name}"
    method              = "POST"
    url_template        = "/logicapps/${data.azurerm_logic_app_standard.logicapp_site.name}/${lower(data.azapi_resource.workflow.name)}"
    description         = "Post a message to a logic app"    
   
    request {
        
    }


    response {
        status_code = 200
        description = "Accepted by the integration platform"        
    }
}

#Manage the policy for this operation
resource "azurerm_api_management_api_operation_policy" "api_operation_policy" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = var.apim_name

    api_name            = azurerm_api_management_api_operation.api_operation.api_name  
    operation_id        = azurerm_api_management_api_operation.api_operation.operation_id

    xml_content = <<XML
   <policies>
    <inbound>
        <base />
        <set-backend-service backend-id="${azurerm_api_management_backend.workflow_backend.name}" />
        <rewrite-uri template="/" copy-unmatched-params="true" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>    
</policies>

XML
}

