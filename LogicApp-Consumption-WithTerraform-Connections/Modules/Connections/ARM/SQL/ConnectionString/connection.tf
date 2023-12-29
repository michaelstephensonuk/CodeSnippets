resource "azurerm_resource_group_template_deployment" "connections_sql" {
    name                = var.deployment_name
    resource_group_name = var.resource_group_name
    deployment_mode = "Incremental"

    # these key-value pairs are passed into the ARM Template's `parameters` block

    parameters_content = jsonencode({
        "arm_sql_Connection_Name" = {
            value = var.connection_name
        },
        "arm_Location" = {
            value = var.connection_location
        },
        "arm_sql_server" = {
            value = var.sql_server
        },
        "arm_sql_database" = {
            value = var.sql_database
        },
        "arm_sql_username" = {
            value = var.sql_username
        },
        "arm_sql_password" = {
            value = var.sql_password
        },
        "arm_sql_encryptConnection" = {
            value = var.sql_encryptConnection
        },
        "arm_sql_privacySetting" = {
            value = var.sql_privacySetting
        },
        "arm_sql_sqlConnectionString" = {
            value = var.sql_sqlConnectionString
        }
    })
  

    template_content  = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "arm_Location": {
      "type": "string",
      "defaultValue": ""      
    },   
    "arm_sql_Connection_Name": {
      "type": "string",
      "defaultValue": ""
    },
    "arm_sql_server": {
      "type": "string",
      "defaultValue": ""
    },
    "arm_sql_database": {
      "type": "string",
      "defaultValue": ""
    },
    "arm_sql_username": {
      "type": "string",
      "defaultValue": ""
    },
    "arm_sql_password": {
      "type": "string",
      "defaultValue": ""
    },
    "arm_sql_encryptConnection": {
      "type": "string",
      "defaultValue": ""
    },
    "arm_sql_privacySetting": {
      "type": "string",
      "defaultValue": ""
    },
    "arm_sql_sqlConnectionString": {
      "type": "string",
      "defaultValue": ""
    }
  },
  "variables": {    
  },
  "resources": [    
    {
      "type": "MICROSOFT.WEB/CONNECTIONS",
      "apiVersion": "2018-07-01-preview",
      "name": "[parameters('arm_sql_Connection_Name')]",
      "location": "[parameters('arm_Location')]",
      "properties": {
        "api": {
          "id": "[concat(subscription().id, '/providers/Microsoft.Web/locations/', parameters('arm_Location'), '/managedApis/', 'sql')]"
        },
        "displayName": "[parameters('arm_sql_Connection_Name')]",
        "parameterValues": {
          "server": "[parameters('arm_sql_server')]",
          "database": "[parameters('arm_sql_database')]",
          "username": "[parameters('arm_sql_username')]",
          "password": "[parameters('arm_sql_password')]",
          "encryptConnection": "[parameters('arm_sql_encryptConnection')]",
          "privacySetting": "[parameters('arm_sql_privacySetting')]",
          "sqlConnectionString": "[parameters('arm_sql_sqlConnectionString')]"          
        }
      }
    }
  ],
  "outputs": {}
}
TEMPLATE


}