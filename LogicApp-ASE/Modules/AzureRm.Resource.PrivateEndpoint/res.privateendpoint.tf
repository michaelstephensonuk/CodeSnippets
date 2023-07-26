
locals {
    private_endpoint_name = "pe-${var.resource_name}-${var.sub_resource_name}"
}
resource "azurerm_private_endpoint" "private_endpoint" {
    name                        = local.private_endpoint_name
    resource_group_name         = var.resource_group_name
    location                    = var.resource_group_location
    subnet_id                   = var.private_endpoint_subnet_id

    private_service_connection {
        name                            = var.resource_name
        is_manual_connection            = "false"
        private_connection_resource_id  = var.resource_id
        subresource_names               = [ var.sub_resource_name ]
    }

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = local.private_endpoint_name
            UsedBy = var.resource_name
            Description = "Private endpoint for ${var.resource_name}"    
            TerraformReference = "azurerm_private_endpoint.private_endpoint"
        }
    )
}


# After the private endpoint is complete we will reference the private endpoint connection to get the ip address when
# setting up the a record
data "azurerm_private_endpoint_connection" "private_endpoint_connection" {    
    name                        = local.private_endpoint_name
    resource_group_name         = var.resource_group_name

    depends_on = [ 
        azurerm_private_endpoint.private_endpoint 
    ]
}


# Create an A record which points the private endpoint address to the private ip address for the resourcet
resource "azurerm_private_dns_a_record" "private_endpoint_a_record" {
    name                        = var.resource_name
    zone_name                   = var.dns_a_record_zone_name
    resource_group_name         = var.resource_group_name
    ttl                         = 300
    
    depends_on = [ 
        azurerm_private_endpoint.private_endpoint,
        data.azurerm_private_endpoint_connection.private_endpoint_connection 
    ]

    records                     = [
        data.azurerm_private_endpoint_connection.private_endpoint_connection.private_service_connection.0.private_ip_address
    ]

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = "dns-a-${var.resource_name}"
            UsedBy = var.resource_name
            Description = "DNS a record for private endpoint"    
            TerraformReference = "azurerm_private_dns_a_record.private_endpoint_a_record"
        }
    )
}


#Setup CName to route the traffic over the private endpoint
resource "azurerm_private_dns_cname_record" "private_endpoint_cname" {
    name                    = var.host_name
    zone_name               = var.dns_c_name_zone_name
    resource_group_name     = var.resource_group_name
    ttl                     = 300
    record                  = var.c_name_record

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = "dns-c-${var.resource_name}"
            UsedBy = var.resource_name
            Description = "DNS CName for private endpoint"    
            TerraformReference = "azurerm_private_dns_cname_record.private_endpoint_cname"
        }
    )
}