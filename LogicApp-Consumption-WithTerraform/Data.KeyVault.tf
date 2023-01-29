
# Resource group the Key Vault belongs to
data "azurerm_resource_group" "keyvault_resource_group" {
  name     = var.keyvault_resource_group
}

# Key vault which we will use the put some of the secrets into
data "azurerm_key_vault" "eai_keyvault" {
  name                = var.keyvault_name
  resource_group_name = data.azurerm_resource_group.keyvault_resource_group.name
}


data "azurerm_key_vault_secret" "synapse_server" {
  name         = "SynapseSQLServer"
  key_vault_id = data.azurerm_key_vault.eai_keyvault.id
}

data "azurerm_key_vault_secret" "synapse_username" {
  name         = "SynapseSQLUsername"
  key_vault_id = data.azurerm_key_vault.eai_keyvault.id
}

data "azurerm_key_vault_secret" "synapse_password" {
  name         = "SynapseSQLPassword"
  key_vault_id = data.azurerm_key_vault.eai_keyvault.id
}

data "azurerm_key_vault_secret" "synapse_database" {
  name         = "SynapseSQLDatabase"
  key_vault_id = data.azurerm_key_vault.eai_keyvault.id
}