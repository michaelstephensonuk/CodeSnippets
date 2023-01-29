##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "logicapps_resource_group" {
  description = "The name of the resource group for logic apps"
  default     = "LogicApp_RG"
}

variable "apim_resource_group" {
  description = "The name of the resource group for APIM"
  default     = "APIM_RG"
}

variable "apim_name" {
  description = "The name of the APIM instance"
  default     = "my-apim"
}

variable "keyvault_name" {
  description = "The name of the Key Vault instance"
  default     = "my-keyvault"
}

variable "keyvault_resource_group" {
  description = "The resource group name of the Key Vault instance"
  default     = "KeyVaultGG"
}

variable "servicebus_name" {
  description = "The name of the service bus namespace"
  default     = "demo-logicapp-testing"
}

variable "servicebus_resource_group" {
  description = "The resource group name of the service bus namespace"
  default     = "ServiceBus-RG"
}

variable "functions_name" {
  description = "The name of the function app"
  default     = "my-functions"
}

variable "functions_resource_group" {
  description = "The resource group name of the function app is"
  default     = "Functions_RG"
}







