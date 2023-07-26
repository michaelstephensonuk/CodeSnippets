locals {
    ase_name = "${local.prefix_app_services_environment}-${local.organization}-${local.product_name}-ase-${var.environment_name}"
    asp_name = "${local.prefix_app_service_plan}-${local.organization}-${local.product_name}-plan-${var.environment_name}"
    ase_pricing_sku     = "I1v2"
}

resource "azurerm_app_service_environment_v3" "ais_ase" {
    name                         = local.ase_name
    resource_group_name          = data.azurerm_resource_group.ais_resource_group.name
    subnet_id                    = azurerm_subnet.ase_outbound.id
    
    internal_load_balancing_mode = "None"

    allow_new_private_endpoint_connections  = true
    
    
    zone_redundant                          = false
    
    #We ignore the below setting because this would set us up using dedicated rather than virtual hardware
    #dedicated_host_count = 1

    cluster_setting {
        name  = "DisableTls1.0"
        value = "1"
    }

    cluster_setting {
        name  = "InternalEncryption"
        value = "true"
    }

    cluster_setting {
        name  = "FrontEndSSLCipherSuiteOrder"
        value = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    }

    lifecycle {
        ignore_changes = [
            # We ignore tags from lifecycle changes as per guidance on below page as this could cause recreation of the resource 
            # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_environment_v3            
            tags
        ]
    }
}

resource "azurerm_service_plan" "ais_app_service_plan" {
    name                       = local.asp_name
    resource_group_name        = data.azurerm_resource_group.ais_resource_group.name
    location                   = data.azurerm_resource_group.ais_resource_group.location
    os_type                    = "Windows"
    sku_name                   = local.ase_pricing_sku
    app_service_environment_id = azurerm_app_service_environment_v3.ais_ase.id
}