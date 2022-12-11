

resource "azurerm_api_management_api" "security_poc_api" {
    name                = "apim-sec-poc-api"
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = data.azurerm_api_management.apim_instance.name
    revision            = "1"
    display_name        = "SEC POC - Test API"
    path                = "secpoc/testapi"
    protocols           = ["https"]      
    description         = "This API is used to help us test the apim validation of a role"        
    service_url         = "https://postman-echo.com"
    subscription_required = false
}

resource "azurerm_api_management_api_policy" "security_poc_api" {
  api_name            = azurerm_api_management_api.security_poc_api.name
  resource_group_name = data.azurerm_resource_group.apim_resource_group.name
  api_management_name = data.azurerm_api_management.apim_instance.name

  xml_content = <<XML
<policies>
    <inbound>

        
        <!-- Remove the APIM header from any downstream calls -->
        <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete"/>

        <base />        
    </inbound>   
</policies>
XML
}

