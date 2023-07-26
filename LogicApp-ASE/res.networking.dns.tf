locals {
    ais_dns_name = "${local.prefix_dns}-${local.organization}-${local.product_name}-${var.environment_name}.lan"

}

resource "azurerm_private_dns_zone" "ais_dns" {
	name					= local.ais_dns_name
	resource_group_name		= data.azurerm_resource_group.ais_resource_group.name

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = local.ais_dns_name
            UsedBy = "DNS zone for the network"
            Description = "Private dns zone for the network"    
            TerraformReference = "azurerm_private_dns_zone.ais_dns_name"
        }
    )
}

# Link the private dns zone to the vnet
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_to_vnet_link" {
	name                        = "dns-vnet-link"
	resource_group_name         = data.azurerm_resource_group.ais_resource_group.name

	private_dns_zone_name       = azurerm_private_dns_zone.ais_dns.name
	virtual_network_id          = azurerm_virtual_network.ais_vnet.id

	tags = merge(
        var.default_tags,
        {
            logicalResourceName = "ais-vnet-link"
            UsedBy = "Private endpoints within the vnet"
            Description = "Private dns zone for the network"    
            TerraformReference = "azurerm_private_dns_zone_virtual_network_link.dns_zone_to_vnet_link"
        }
    )

    depends_on = [ 
        azurerm_virtual_network.ais_vnet,
        azurerm_private_dns_zone.ais_dns
    ]
}


# Create a private dns zone for each resource type in the private link list
resource "azurerm_private_dns_zone" "resource_type_dnszone" {
	for_each = var.private_endpoint_dns_list

	name                        = each.value["private_link"]
	resource_group_name         = data.azurerm_resource_group.ais_resource_group.name 
	
	tags = merge(
        var.default_tags,
        {
            logicalResourceName = each.value["private_link"]
            UsedBy = "Vnet"
            Description = "Private dns zone for each private link"    
            TerraformReference = "azurerm_private_dns_zone.resource_type_dnszone"
        }
    )

    depends_on = [ 
        azurerm_private_dns_zone_virtual_network_link.dns_zone_to_vnet_link
    ]
}

# Link the private dns zone to the virtual network for database
resource "azurerm_private_dns_zone_virtual_network_link" "resource_type_dnszone_to_vnet_link" {
	for_each = var.private_endpoint_dns_list

	resource_group_name         = data.azurerm_resource_group.ais_resource_group.name  
	virtual_network_id          = azurerm_virtual_network.ais_vnet.id

	name                        = azurerm_private_dns_zone.resource_type_dnszone[each.key].name	
	private_dns_zone_name       = azurerm_private_dns_zone.resource_type_dnszone[each.key].name
	
	tags = merge(
        var.default_tags,
        {
            logicalResourceName = "dns_to_vnet_link_${each.value["private_link"]}"
            UsedBy = "Private endpoints within the vnet"
            Description = "Register dns zone for vnet private link"    
            TerraformReference = "azurerm_private_dns_zone_virtual_network_link.resource_type_dnszone_to_vnet_link"
        }
    )

    depends_on = [ 
        azurerm_private_dns_zone_virtual_network_link.dns_zone_to_vnet_link
    ]
}

# This is a list of dns zones we need to add for the various resource types which need
# private endpoints
variable "private_endpoint_dns_list" {
    description = "The list of dns zones to add"
    type = map(object({
        private_link = string    
        name = string
    }))
    default = {
        app_service = {
            private_link = "privatelink.azurewebsites.net",
            name = "privatelink.azurewebsites.net"
        },
        keyvault = {
            private_link = "privatelink.vaultcore.azure.net",
            name = "privatelink.vaultcore.azure.net"
        },
        storage_dfs = {
            private_link = "privatelink.dfs.core.windows.net",
            name = "privatelink.dfs.core.windows.net"
        },        
        storage_blob = {
            private_link = "privatelink.blob.core.windows.net",
            name = "privatelink.blob.core.windows.net"
        },
    }
}
