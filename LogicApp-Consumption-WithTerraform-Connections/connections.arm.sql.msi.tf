

variable "connections_arm_sql_msi_list" {
  description = "A list of connection names to create"
  type        = list(string)
  default     = [
    "sql-msi-by-arm-connection-1", 
    "sql-msi-by-arm-connection-2", 
    "sql-msi-by-arm-connection-3"
    ]
}

module "connections_arm_sql_msi" {
    source = "./Modules/Connections/ARM/SQL/MSI"

    for_each                = toset(var.connections_arm_sql_msi_list)
    
    resource_group_name     = data.azurerm_resource_group.ais_resource_group.name
    deployment_name         = "${local.prefix_api_connection}-${each.key}"
    connection_location     = data.azurerm_resource_group.ais_resource_group.location
    connection_name         = "${local.prefix_api_connection}-${each.key}"
    
      
}