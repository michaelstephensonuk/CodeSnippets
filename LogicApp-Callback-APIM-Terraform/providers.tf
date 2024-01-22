terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.87.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "1.11.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
    features {
        key_vault {
	        recover_soft_deleted_key_vaults = true
            purge_soft_delete_on_destroy = true
        }
    }
}


provider "azapi" {
  # Configuration options
}
