locals {
    
    ais_storage_account_name = "${local.prefix_storage}${local.organization}${local.product_name}${var.environment_name}"
    ais_storage_firewall_allow_list = [ local.build_agent_ip ] 
}

resource "azurerm_storage_account" "ais_storage" {
    name                        = local.ais_storage_account_name
    location                    = data.azurerm_resource_group.ais_resource_group.location
    resource_group_name         = data.azurerm_resource_group.ais_resource_group.name
  
    is_hns_enabled              = true
    
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
            UsedBy = "Various AIS interfaces"
            Description = "Storage account which is the AIS platform"    
            TerraformReference = "azurerm_storage_account.ais_storage"
        }
    )
}

resource "azurerm_storage_account_network_rules" "ais_storage_network_rules" {
    
    storage_account_id          = azurerm_storage_account.ais_storage.id
    default_action              = "Deny"
    virtual_network_subnet_ids  = [
        # This would allow access to subnets which are not coming through the private endpoint
                                ]
    
    #We will set this to a variable which in dev2 allows terraform dev to access storage but in
    #real environments it will be an empty array because resources will be on the network
    ip_rules = local.ais_storage_firewall_allow_list

    bypass                      = ["None"]

    lifecycle {
        ignore_changes = [
            #Once the storage is setup and we apply this rule for the build agent we
            # will ignore changes for private link area 
            private_link_access
        ]
    }
}

module "storage_private_endpoint_ais_storage_dfs" {
    source = "./modules/AzureRm.Resource.PrivateEndpoint"
    
    resource_group_name             = azurerm_storage_account.ais_storage.resource_group_name
    resource_group_location         = azurerm_storage_account.ais_storage.location
    resource_name                   = azurerm_storage_account.ais_storage.name
    resource_id                     = azurerm_storage_account.ais_storage.id
    private_endpoint_subnet_id      = azurerm_subnet.private_endpoints.id
    sub_resource_name               = "dfs"
    dns_c_name_zone_name            = azurerm_private_dns_zone.ais_dns.name
    dns_a_record_zone_name          = var.private_endpoint_dns_list["storage_dfs"].name
    host_name                       = azurerm_storage_account.ais_storage.primary_dfs_host 
    default_tags                    = var.default_tags
    c_name_record                   = "${azurerm_storage_account.ais_storage.name}.${var.private_endpoint_dns_list["storage_dfs"].private_link}"
}

module "storage_private_endpoint_ais_storage_blob" {
    source = "./modules/AzureRm.Resource.PrivateEndpoint"
    
    resource_group_name             = azurerm_storage_account.ais_storage.resource_group_name
    resource_group_location         = azurerm_storage_account.ais_storage.location
    resource_name                   = azurerm_storage_account.ais_storage.name
    resource_id                     = azurerm_storage_account.ais_storage.id
    private_endpoint_subnet_id      = azurerm_subnet.private_endpoints.id
    sub_resource_name               = "blob"    
    dns_c_name_zone_name            = azurerm_private_dns_zone.ais_dns.name
    dns_a_record_zone_name          = var.private_endpoint_dns_list["storage_blob"].name
    host_name                       = azurerm_storage_account.ais_storage.primary_blob_host 
    default_tags                    = var.default_tags
    c_name_record                   = "${azurerm_storage_account.ais_storage.name}.${var.private_endpoint_dns_list["storage_blob"].private_link}"
}

resource "azurerm_storage_container" "test_container" {
    name                  = "testing"
    storage_account_name  = azurerm_storage_account.ais_storage.name
    container_access_type = "private"
}

resource "azurerm_storage_blob" "public_image" {
  name                   = "mike.txt"
  storage_account_name   = azurerm_storage_account.ais_storage.name
  storage_container_name = azurerm_storage_container.test_container.name
  type                   = "Block"
  source                 = "Mike.txt"
}






