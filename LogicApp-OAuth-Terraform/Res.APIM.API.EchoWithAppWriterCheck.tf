

resource "azurerm_api_management_api_operation" "security_poc_api_echo_appwriter_rolecheck" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = data.azurerm_api_management.apim_instance.name

    api_name            = azurerm_api_management_api.security_poc_api.name  

    operation_id        = "apim-sec-poc-api-echo-appwriter-role-check"
    
    display_name        = "Echo with AppWriter Role Check"
    method              = "GET"
    url_template        = "/echo/appwriter/rolecheck"
    description         = "Forwards a message postman and returns a response but validates the jwt token"    
   

    request {
        
    }
    
    response {
        status_code = 200        
    }
}

#Operation Policy
resource "azurerm_api_management_api_operation_policy" "security_poc_api_echo_appwriter_rolecheck" {
    resource_group_name = data.azurerm_resource_group.apim_resource_group.name
    api_management_name = data.azurerm_api_management.apim_instance.name
    api_name            = azurerm_api_management_api.security_poc_api.name   
    operation_id        = azurerm_api_management_api_operation.security_poc_api_echo_appwriter_rolecheck.operation_id

    xml_content = <<XML
   <policies>
    <inbound>
        <base />

        <validate-jwt header-name="Authorization" failed-validation-httpcode="401" require-scheme="Bearer"
            failed-validation-error-message="Token invalid" output-token-variable-name="jwt">
            <openid-config url="https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0/.well-known/openid-configuration" />
            <audiences>
                <audience>${azuread_application.apim_security_roles.application_id}</audience>
            </audiences>
            <issuers>
                <issuer>https://sts.windows.net/${data.azuread_client_config.current.tenant_id}/</issuer>
            </issuers>
            <required-claims>
              <claim name="roles" match="any">
                <value>${local.apim_security_roles_names.AppWriter}</value>
              </claim>
            </required-claims>
        </validate-jwt>

        <!-- Remove the Auth header before sending to postman -->
        <set-header name="Authorization" exists-action="delete"/>
        
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