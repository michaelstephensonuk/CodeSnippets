# Configure the terraform providers which will be used in this workspace

terraform {
  required_providers {
    null = {
      source    = "hashicorp/null"
      version   = "3.1.0"
    }

    http = {
      source    = "hashicorp/http"
      version   = "2.1.0"
    }

    random = {
      source    = "hashicorp/random"
      version   = "3.1.0"
    }

    azuread = {
      source = "hashicorp/azuread"
      version = "2.40.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.66.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "1.7.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "azuread" {
  # Configuration options
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
provider "local" {
  # Configuration options
}

provider "template" {
  # Configuration options
}