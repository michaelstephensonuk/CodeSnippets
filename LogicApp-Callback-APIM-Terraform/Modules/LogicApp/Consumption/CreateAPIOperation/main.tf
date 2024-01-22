



//Read Logic App Resource Group
data "azurerm_resource_group" "logicapp_resource_group" {
  name = var.logicapp_resource_group_name
}

//Read APIM Resource Group
data "azurerm_resource_group" "apim_resource_group" {
  name = var.apim_resource_group_name
}

//Read Logic App Resource
data "azapi_resource" "logicapp_resource" {
	name      = var.logicapp_name
	parent_id = data.azurerm_resource_group.logicapp_resource_group.id
	type      = "Microsoft.Logic/workflows@2019-05-01"

	response_export_values = ["*"]
}

//Read the call back url for the Logic App
data "azapi_resource_action" "logicapp_callbackurl" {
  type                   = "Microsoft.Logic/workflows@2019-05-01"
  resource_id            = data.azapi_resource.logicapp_resource.id
  action                 = "/triggers/manual/listCallbackUrl"
  response_export_values = ["*"]
}

# Create a backend to represent the API
resource "azurerm_api_management_backend" "logicapp_backend" {
    name                = data.azapi_resource.logicapp_resource.name
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = var.apim_name
    protocol            = "http"
    url                 = jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).basePath

    credentials {
        query = {
            "api-version"   = jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.api-version
            "sig"           = jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.sig
            "sp"            = jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.sp
            "sv"            = jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.sv
        }
  }
}

#Manage the operation within the API for this logic app
resource "azurerm_api_management_api_operation" "api_operation" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = var.apim_name
    
    operation_id        = "${data.azapi_resource.logicapp_resource.name}-post"

    api_name            = var.apim_api_name  

    display_name        = "Logic App - ${data.azapi_resource.logicapp_resource.name}"
    method              = "POST"
    url_template        = "/logicapps/${lower(data.azapi_resource.logicapp_resource.name)}"
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
        <set-backend-service backend-id="${azurerm_api_management_backend.logicapp_backend.name}" />
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