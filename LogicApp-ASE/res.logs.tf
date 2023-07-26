
locals {
    log_analytics_name = "${local.prefix_loganalytics}-${local.organization}-${local.product_name}-${var.environment_name}"
    app_insights_name = "${local.prefix_appinsights}-${local.organization}-${local.product_name}-${var.environment_name}"
}

resource "azurerm_log_analytics_workspace" "ais_logs" {
    name                = local.log_analytics_name
    location            = data.azurerm_resource_group.ais_resource_group.location
    resource_group_name = data.azurerm_resource_group.ais_resource_group.name
    sku                 = "PerGB2018"
    retention_in_days   = 30

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = local.app_insights_name
            UsedBy = "Various logic app and function apps" 
            Description = "Used for logging telemetry from apps"    
            TerraformReference = "azurerm_log_analytics_workspace.app_logs"
        }
    )
}

resource "azurerm_application_insights" "ais_logs" {
    name                    = local.app_insights_name
    location                = data.azurerm_resource_group.ais_resource_group.location
    resource_group_name     = data.azurerm_resource_group.ais_resource_group.name
    workspace_id            = azurerm_log_analytics_workspace.ais_logs.id
    application_type        = "web"

    tags = merge(
        var.default_tags,
        {
            logicalResourceName = local.app_insights_name
            UsedBy = "Various logic app and function apps" 
            Description = "Used for logging telemetry from apps"    
            TerraformReference = "azurerm_application_insights.app_logs"
        }
    )
}
