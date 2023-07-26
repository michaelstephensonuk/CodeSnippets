locals {
    vnet_name = "${local.prefix_vnet}-${local.organization}-${local.product_name}-${var.environment_name}"

    vnet_address_space                      = "10.0.0.0/16"
    ase_subnet_address                      = "10.0.1.0/24"
    private_endpoints_subnet_address        = "10.0.2.0/24"
    gateway_subnet_address                  = "10.0.3.0/24"
    
}


resource "azurerm_virtual_network" "ais_vnet" {
    name                = local.vnet_name
    location            = data.azurerm_resource_group.ais_resource_group.location
    resource_group_name = data.azurerm_resource_group.ais_resource_group.name
    address_space       = [ local.vnet_address_space ]

    depends_on = [ 
            azurerm_private_dns_zone.ais_dns 
        ]
}

resource "azurerm_subnet" "ase_outbound" {
    name                 = "ase-subnet-outbound"
    resource_group_name  = data.azurerm_resource_group.ais_resource_group.name
    virtual_network_name = azurerm_virtual_network.ais_vnet.name
    address_prefixes     = [ local.ase_subnet_address ]

    delegation {
        name = "Microsoft.Web.hostingEnvironments"
        service_delegation {
            name    = "Microsoft.Web/hostingEnvironments"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
    }

    service_endpoints    = [ 
                                "Microsoft.KeyVault", 
                                "Microsoft.Storage",
                                "Microsoft.Web",
                                "Microsoft.Sql",
                                "Microsoft.AzureActiveDirectory",
                                "Microsoft.EventHub",
                                "Microsoft.AzureCosmosDB"
                            ]
}




resource "azurerm_subnet" "private_endpoints" {
    name                        = "ais-private-endpoints"
    resource_group_name         = data.azurerm_resource_group.ais_resource_group.name
    virtual_network_name        = azurerm_virtual_network.ais_vnet.name
    address_prefixes            = [ local.private_endpoints_subnet_address ]

    service_endpoints           = [ 
                                  "Microsoft.KeyVault", 
                                  "Microsoft.Storage",
                                  "Microsoft.Web",
                                  "Microsoft.Sql",
                                  "Microsoft.AzureActiveDirectory",
                                  "Microsoft.EventHub",
                                  "Microsoft.AzureCosmosDB"
                                ]

    private_link_service_network_policies_enabled   = true
    private_endpoint_network_policies_enabled       = true
    
}

