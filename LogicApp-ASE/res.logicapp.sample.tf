
locals {
    sample_logicapp_name = "sample"
    sample_logicapp_name_fullname = "${local.prefix_logicapp_standard}-${local.organization}-${local.product_name}${local.sample_logicapp_name}-${var.environment_name}"
    sample_logicapp_storage_account_name = "${local.prefix_storage}${local.organization}${local.product_name}${local.prefix_logicapp_standard}${local.sample_logicapp_name}${var.environment_name}"
}

resource "azurerm_storage_account" "logicapp_sample_storage" {
    name                        = local.sample_logicapp_storage_account_name
    location                    = data.azurerm_resource_group.ais_resource_group.location
    resource_group_name         = data.azurerm_resource_group.ais_resource_group.name
      
    # Note we are changing allow_blob_public_access to use allow_nested_items_to_be_public which is a change of name for a property
    allow_nested_items_to_be_public = false

    enable_https_traffic_only   = true
    account_kind                = "StorageV2"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    min_tls_version             = "TLS1_2"
  
    tags = merge(
        var.default_tags,
        {
            logicalResourceName = local.ais_storage_account_name
            UsedBy = "Logic App - sample_logicapp_name_fullname"
            Description = "Storage account used by the logic app"    
            TerraformReference = "azurerm_storage_account.logicapp_sample_storage"
        }
    )
}

resource "azurerm_logic_app_standard" "sample" {
    name                            = local.sample_logicapp_name_fullname
    location                        = data.azurerm_resource_group.ais_resource_group.location
    resource_group_name             = data.azurerm_resource_group.ais_resource_group.name
    app_service_plan_id             = azurerm_service_plan.ais_app_service_plan.id

    storage_account_name            = azurerm_storage_account.logicapp_sample_storage.name
    storage_account_access_key      = azurerm_storage_account.logicapp_sample_storage.primary_access_key
    storage_account_share_name      = "${lower(local.sample_logicapp_name_fullname)}-content"

    https_only                    = true
    version                       = "~4"

    use_extension_bundle          = "true"
    bundle_version                = "[1.*, 2.0.0)"
    

    app_settings = {
        "WEBSITE_VNET_ROUTE_ALL"                            = "1"
        "FUNCTIONS_WORKER_RUNTIME"                          = "node"
        "WEBSITE_NODE_DEFAULT_VERSION"                      = "~14"
        
        "APPINSIGHTS_INSTRUMENTATIONKEY"                    = azurerm_application_insights.ais_logs.instrumentation_key
        "APPINSIGHTS_CONNECTIONSTRING"                      = azurerm_application_insights.ais_logs.connection_string
                
        # These settings are used by Logic Apps to use the cloud connectors
        "WORKFLOWS_TENANT_ID": data.azurerm_client_config.current.tenant_id
        "WORKFLOWS_SUBSCRIPTION_ID": data.azurerm_client_config.current.subscription_id
        "WORKFLOWS_RESOURCE_GROUP_NAME": data.azurerm_resource_group.ais_resource_group.name
        "WORKFLOWS_LOCATION_NAME": data.azurerm_resource_group.ais_resource_group.location
        "WORKFLOWS_MANAGEMENT_BASE_URI": "https://management.azure.com/"
        
        "KeyVault_Test_Secret" = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.ais_key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.test_secret.name})"

        # For reference the below settings will appear in the app settings, but they are not set directly here they are
        # set by the terraform resource under the hood
        # leaving this here for documentation of why they are not set
        #"FUNCTIONS_EXTENSION_VERSION"                       = "~4"
        #"AzureFunctionsJobHost__extensionBundle__id"        = "Microsoft.Azure.Functions.ExtensionBundle.Workflows"
        #"AzureFunctionsJobHost__extensionBundle__version"   = "[1.*, 2.0.0)"
        #"AzureWebJobsStorage"                               = data.azurerm_storage_account.eai_logicapps_storage.primary_access_key
    }

    site_config {
        always_on                   = false
        dotnet_framework_version    = "v6.0"
        ftps_state                  = "Disabled"
        pre_warmed_instance_count   = "1"
        app_scale_limit             = "1"
    }

    identity  {
        type                        = "SystemAssigned"        
    }

    lifecycle {
        ignore_changes = [
            app_settings["WEBSITE_RUN_FROM_PACKAGE"],
            app_settings["MSDEPLOY_RENAME_LOCKED_FILES"],   
            app_settings["WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"],   
            app_settings["WEBSITE_CONTENTSHARE"],   
            tags["hidden-link: /app-insights-instrumentation-key"],   
            tags["hidden-link: /app-insights-resource-id"],   
            id
        ]
    }

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = local.sample_logicapp_name_fullname
            UsedBy = "EAI platform" 
            Description = "Sample logic app to demo"    
            TerraformReference = "azurerm_logic_app_standard.sample"
        }
    ) 

}

# This will give permission to the logic app system assigned managed identity to access the keyvault for keyvault references
resource "azurerm_key_vault_access_policy" "logicapp_sample" {
    key_vault_id = azurerm_key_vault.ais_key_vault.id
    tenant_id    = data.azurerm_client_config.current.tenant_id

    object_id    = azurerm_logic_app_standard.sample.identity[0].principal_id

    secret_permissions = [
        "Get",
        "List"
    ]

    depends_on = [
            azurerm_logic_app_standard.sample            
        ]
}