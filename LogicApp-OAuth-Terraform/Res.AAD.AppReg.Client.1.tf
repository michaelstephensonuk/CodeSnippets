

resource "azuread_application" "client_1" {
    display_name                = "${var.aad_object_prefix}-${data.azurerm_api_management.apim_instance.name}-Client-1"
    
    owners                      = [
                                    data.azuread_client_config.current.object_id
                                ]     

    single_page_application {
        redirect_uris           = [
                                    "https://${var.aad_object_prefix}-${data.azurerm_api_management.apim_instance.name}-Client-1/"
                                ]    
    }

    required_resource_access {
        resource_app_id = azuread_application.apim_security_roles.application_id

        resource_access {
            id   = azuread_service_principal.apim_security_roles.app_role_ids[local.apim_security_roles_names.AppReader]
            type = "Role"
        }
    } 
}

# Create a secret for the App Registration
resource "azuread_application_password" "client_1" {
  application_object_id = azuread_application.client_1.object_id

  display_name = "test-secret"
}

# Create a Service Principal (Enterprise Application for the App Registration)
resource "azuread_service_principal" "client_1" {
  application_id = azuread_application.client_1.application_id

  description = "Enterprise Application for app registration: ${azuread_application.client_1.display_name}.  This is used for the APIM sec poc demo"
}

resource "azuread_app_role_assignment" "client_1" {
    
    # The object id you want to give permissions to
    principal_object_id = azuread_service_principal.client_1.object_id
  
    # Which object do you want access to
    resource_object_id  = azuread_service_principal.apim_security_roles.object_id

    # Which roles do you want access to
    app_role_id         = azuread_service_principal.apim_security_roles.app_role_ids[local.apim_security_roles_names.AppReader]
}
