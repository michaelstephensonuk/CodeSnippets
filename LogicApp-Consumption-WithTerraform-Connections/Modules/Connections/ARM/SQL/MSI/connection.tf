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
        }
    })
  

    template_content  = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "arm_Location": {
      "type": "string",
      "defaultValue": "westus2"      
    },   
    "arm_sql_Connection_Name": {
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
        "parameterValueSet": {
          "name": "oauthMI",
          "values": {}
        }
      }
    }
  ],
  "outputs": {}
}
TEMPLATE


}