

resource "azurerm_api_management_api_operation" "security_poc_api_echo" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = data.azurerm_api_management.apim_instance.name

    api_name            = azurerm_api_management_api.security_poc_api.name  

    operation_id        = "apim-sec-poc-api-echo"
    
    display_name        = "Echo"
    method              = "GET"
    url_template        = "/echo"
    description         = "Forwards a message postman and returns a response"    
   

    request {
        
    }
    
    response {
        status_code = 200        
    }
}

#Operation Policy
resource "azurerm_api_management_api_operation_policy" "security_poc_api_echo" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = data.azurerm_api_management.apim_instance.name
    api_name            = azurerm_api_management_api.security_poc_api.name   
    operation_id        = azurerm_api_management_api_operation.security_poc_api_echo.operation_id

    xml_content = <<XML
   <policies>
    <inbound>
        <base />
        
        
        <set-variable name="logicAppName" value="@(context.Request.Headers.GetValueOrDefault("x-ms-workflow-name", "Unknown"))" />
        <set-variable name="logicAppRunId" value="@(context.Request.Headers.GetValueOrDefault("x-ms-workflow-run-id", "Unknown"))" />
        <rewrite-uri template="/get" copy-unmatched-params="true" />
        
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />

    </outbound>
    <on-error>
        <base />
        <set-variable name="errorMessage" value="@{
            return new JObject(
                new JProperty("EventTime", DateTime.UtcNow.ToString()),
                new JProperty("ErrorMessage", context.LastError.Message),
                new JProperty("ErrorReason", context.LastError.Reason),
                new JProperty("ErrorSource", context.LastError.Source),
                new JProperty("ErrorScope", context.LastError.Scope),
                new JProperty("ErrorSection", context.LastError.Section)

            ).ToString();
        }" />
        <return-response>
            <set-status code="500" reason="Error" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@((string)context.Variables["errorMessage"])</set-body>
        </return-response>
    </on-error>
</policies>

XML
}