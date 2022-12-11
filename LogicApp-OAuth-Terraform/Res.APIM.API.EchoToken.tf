

resource "azurerm_api_management_api_operation" "security_poc_api_echo_token" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = data.azurerm_api_management.apim_instance.name

    api_name            = azurerm_api_management_api.security_poc_api.name  

    operation_id        = "apim-sec-poc-api-echo-token"
    
    display_name        = "Echo Token"
    method              = "GET"
    url_template        = "/echo/token"
    description         = "Returns the content of the token"    
   

    request {
        
    }
    
    response {
        status_code = 200        
    }
}

#Operation Policy
resource "azurerm_api_management_api_operation_policy" "security_poc_api_echo_token" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = data.azurerm_api_management.apim_instance.name
    api_name            = azurerm_api_management_api.security_poc_api.name   
    operation_id        = azurerm_api_management_api_operation.security_poc_api_echo_token.operation_id

    xml_content = <<XML
   <policies>
    <inbound>
        <base />

        <validate-jwt header-name="Authorization" failed-validation-httpcode="401" require-scheme="Bearer"
            failed-validation-error-message="Token invalid" output-token-variable-name="jwt">
            <openid-config url="https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0/.well-known/openid-configuration" />            
            <issuers>
                <issuer>https://sts.windows.net/${data.azuread_client_config.current.tenant_id}/</issuer>
            </issuers>            
        </validate-jwt>

        <return-response>
            <set-status code="200" reason="Ok" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@{
            Jwt jwt = (Jwt)context.Variables["jwt"];
            return JsonConvert.SerializeObject(jwt);
            
            }</set-body>
        </return-response>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />

    </outbound>
    <on-error>
        <base />
        <!--
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
        -->
    </on-error>
</policies>

XML
}