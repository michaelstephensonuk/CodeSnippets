
locals {
  # Common tags to be assigned to all resources
  apim_security_roles_ids = {
    AppReader = "dfa995c6-00ad-418b-8aba-e7f397c2b1bd"
    AppWriter   = "1b19509b-32b1-4e9f-b71d-4992aa991967"
  }

  apim_security_roles_names = {
    AppReader = "App.Reader"
    AppWriter   = "App.Writer"
  }
}

# Create an app registration which is used in APIM to validate the caller has a token which points to this app registration
# we will also check the roles on the token ensure that the caller has those roles assigned to them
resource "azuread_application" "apim_security_roles" {
    display_name                = "${var.aad_object_prefix}-${data.azurerm_api_management.apim_instance.name}-Security-Roles"
    identifier_uris = [
                        "api://${var.aad_object_prefix}-${data.azurerm_api_management.apim_instance.name}-Security-Roles"
                      ]

    owners                      = [
                                    data.azuread_client_config.current.object_id
                                  ]

    app_role {
      allowed_member_types = ["Application"]
      description          = "Reader Role for the API"
      display_name         = local.apim_security_roles_names.AppReader
      enabled              = true
      id                   = local.apim_security_roles_ids.AppReader
      value                = "App.Reader"
    }

    app_role {
      allowed_member_types = ["Application"]
      description          = "Writer Role for the API"
      display_name         = local.apim_security_roles_names.AppWriter
      enabled              = true
      id                   = local.apim_security_roles_ids.AppWriter
      value                = "App.Writer"
    }
    
}

# Create a Service Principal (Enterprise Application for the App Registration)
resource "azuread_service_principal" "apim_security_roles" {
  application_id = azuread_application.apim_security_roles.application_id
}
