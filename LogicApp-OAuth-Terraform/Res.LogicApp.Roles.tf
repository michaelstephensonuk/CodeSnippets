

# Give the user assigned managed identity for the logic app a role assignment which will set it up to
# have access for the backend apim service principal
resource "azuread_app_role_assignment" "logicapp" {
    
    # The object id you want to give permissions to
    principal_object_id = azurerm_user_assigned_identity.logicapp.principal_id 
      
    # Which object do you want access to
    resource_object_id  = azuread_service_principal.apim_security_roles.object_id

    # Which roles do you want access to
    app_role_id         = azuread_service_principal.apim_security_roles.app_role_ids[local.apim_security_roles_names.AppReader]
}



resource "azurerm_logic_app_workflow" "logicapp_roles" {
    name                = "APIM-SEC-POC-Roles-Demo"
    location            = azurerm_resource_group.logicapp.location
    resource_group_name = azurerm_resource_group.logicapp.name
    
    identity {
        type  =   "UserAssigned"
        identity_ids = [ azurerm_user_assigned_identity.logicapp.id ]
    }

    workflow_parameters = {
        "aad_tenant_id" = jsonencode(
                {
                  defaultValue = data.azuread_client_config.current.tenant_id
                  type         = "String"
                }
            ),
        "client1_client_id" = jsonencode(
                {
                  defaultValue = azuread_application.client_1.application_id
                  type         = "String"
                }
            ),
        "client1_client_secret" = jsonencode(
                {
                  defaultValue = azuread_application_password.client_1.value
                  type         = "SecureString"
                }
            ),
        "target_app_reg_clientid" = jsonencode(
                {
                  defaultValue = "${azuread_application.apim_security_roles.application_id}"
                  type         = "String"
                }
            ),
        "target_app_reg_identifier" = jsonencode(
                {
                  defaultValue = "${tolist(azuread_application.apim_security_roles.identifier_uris)[0]}/.default"
                  type         = "String"
                }
            )
    }
}