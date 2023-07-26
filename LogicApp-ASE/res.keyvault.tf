locals {
    key_vault_name = "${local.prefix_keyvault}-${local.organization}-${local.product_name}-${var.environment_name}"
    key_vault_firewall_allow_list = [ local.build_agent_ip ]

    keyvault_private_link = var.private_endpoint_dns_list["keyvault"].private_link

}

resource "azurerm_key_vault" "ais_key_vault" {
    name                = local.key_vault_name
    location            = data.azurerm_resource_group.ais_resource_group.location
    resource_group_name = data.azurerm_resource_group.ais_resource_group.name

    sku_name = "standard"

    enable_rbac_authorization       = false
    enabled_for_deployment          = true
    enabled_for_template_deployment = true
    enabled_for_disk_encryption     = true
    tenant_id                       = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days      = 7
    purge_protection_enabled        = true 

    network_acls {
        default_action             = "Deny"
        bypass                     = "AzureServices"

        virtual_network_subnet_ids = [ 
            #This will allow the ASE outbound ip's to access key vault but it wouldnt be via the private endpoint
            #lower(azurerm_subnet.ase_outbound.id)

            #You may want to allow a build agent subnet to have access here

        ]
        
        ip_rules = local.key_vault_firewall_allow_list
    }

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = "AIS KeyVault"
            UsedBy = "Various interfaces" 
            Description = "Secrets and Certs for the AIS platform"    
            TerraformReference = "azurerm_key_vault.ais_key_vault"
        }
    )   
}




module "keyvault_private_endpoint" {
    source = "./modules/AzureRm.Resource.PrivateEndpoint"
    
    resource_group_name             = azurerm_key_vault.ais_key_vault.resource_group_name
    resource_group_location         = azurerm_key_vault.ais_key_vault.location
    resource_name                   = azurerm_key_vault.ais_key_vault.name
    resource_id                     = azurerm_key_vault.ais_key_vault.id
    private_endpoint_subnet_id      = azurerm_subnet.private_endpoints.id
    sub_resource_name               = "vault"

    dns_c_name_zone_name            = azurerm_private_dns_zone.ais_dns.name
    c_name_record                   = "${azurerm_key_vault.ais_key_vault.name}.${local.keyvault_private_link}"

    dns_a_record_zone_name          = var.private_endpoint_dns_list["keyvault"].name
    host_name                       = "${azurerm_key_vault.ais_key_vault.name}.vault.azure.net"
    
    default_tags                    = var.default_tags    
}

#Add a test secret so we can use this to check network connectivity
resource "azurerm_key_vault_secret" "test_secret" {
    
    name         = "KVS-Test-Secret"
    value        = "Networking test secret setup by terraform"
    key_vault_id = azurerm_key_vault.ais_key_vault.id


    #Make sure this explicitly waits for the keyvault creation to complete
    depends_on = [
        azurerm_key_vault.ais_key_vault
    ] 
}

