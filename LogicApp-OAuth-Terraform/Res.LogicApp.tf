



resource "azurerm_resource_group" "logicapp" {
    name     = "Blog_LogicApp_APIMSecPOC"
    location = data.azurerm_resource_group.apim_resource_group.location
}

resource "azurerm_user_assigned_identity" "logicapp" {
    name                = "apim-sec-poc-logicapp"

    location            = azurerm_resource_group.logicapp.location  
    resource_group_name = azurerm_resource_group.logicapp.name
}







resource "azurerm_logic_app_workflow" "logicapp" {
    name                = "APIM-SEC-POC"
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


