
# A queue which will be used by the logic app
resource "azurerm_servicebus_queue" "demo_logicap_1" {
    name         = "Demo-LogicApp-1-Queue"
    namespace_id = data.azurerm_servicebus_namespace.servicebus.id

    enable_partitioning = true
}

# Create qn authorization rule to allow the logic app to talk to the queue
resource "azurerm_servicebus_queue_authorization_rule" "demo_logicap_1" {
    name     = "Demo-LogicApp-1-Queue-Rule"
    queue_id = azurerm_servicebus_queue.demo_logicap_1.id

    listen = true
    send   = true
    manage = false
}

# Add the Service Bus key to key vault
resource "azurerm_key_vault_secret" "demo_logicap_1_servicebus_key" {
  name         = "Demo-LogicApp-1-ServiceBus-Queue-SAS"
  value        = azurerm_servicebus_queue_authorization_rule.demo_logicap_1.primary_connection_string
  key_vault_id = data.azurerm_key_vault.eai_keyvault.id
}



