
locals{
    connections_arm_sql_withconnectionstring_list = [
        {
            name = "sql-connstring-by-arm-connection-1"
            sql_server = data.azurerm_key_vault_secret.synapse_server.value
            sql_database = data.azurerm_key_vault_secret.synapse_database.value
            sql_username = data.azurerm_key_vault_secret.synapse_username.value
            sql_password = data.azurerm_key_vault_secret.synapse_password.value
        },
        {
            name = "sql-connstring-by-arm-connection-2"
            sql_server = data.azurerm_key_vault_secret.synapse_server.value
            sql_database = data.azurerm_key_vault_secret.synapse_database.value
            sql_username = data.azurerm_key_vault_secret.synapse_username.value
            sql_password = data.azurerm_key_vault_secret.synapse_password.value
        },
        {
            name = "sql-connstring-by-arm-connection-3"
            sql_server = data.azurerm_key_vault_secret.synapse_server.value
            sql_database = data.azurerm_key_vault_secret.synapse_database.value
            sql_username = data.azurerm_key_vault_secret.synapse_username.value
            sql_password = data.azurerm_key_vault_secret.synapse_password.value
        }
    ]
}


module "connections_arm_sql_withconnectionstring" {
    source = "./Modules/Connections/ARM/SQL/ConnectionString"

    count       = length(local.connections_arm_sql_withconnectionstring_list)
    
    resource_group_name     = data.azurerm_resource_group.ais_resource_group.name
    deployment_name         = "${local.prefix_api_connection}-${local.connections_arm_sql_withconnectionstring_list[count.index].name}"
    connection_location     = data.azurerm_resource_group.ais_resource_group.location
    connection_name         = "${local.prefix_api_connection}-${local.connections_arm_sql_withconnectionstring_list[count.index].name}"
    
    sql_server              = local.connections_arm_sql_withconnectionstring_list[count.index].sql_server
    sql_database            = local.connections_arm_sql_withconnectionstring_list[count.index].sql_database
    sql_username            = local.connections_arm_sql_withconnectionstring_list[count.index].sql_username
    sql_password            = local.connections_arm_sql_withconnectionstring_list[count.index].sql_password
    
      
}