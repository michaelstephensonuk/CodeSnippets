##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "logicapps_resource_group" {
  description = "The name of the resource group for logic apps"
  default     = "Blog_LogicApp_Consumption_Terraform"
}

variable "apim_resource_group" {
  description = "The name of the resource group for APIM"
  default     = "Blog_APIM_and_Frontdoor"
}

variable "apim_name" {
  description = "The name of the APIM instance"
  default     = "ms-blog-apim"
}

variable "keyvault_name" {
  description = "The name of the Key Vault instance"
  default     = "MikesKeyVault1"
}

variable "keyvault_resource_group" {
  description = "The resource group name of the Key Vault instance"
  default     = "Blog_LogicApp_Config"
}

variable "servicebus_name" {
  description = "The name of the service bus namespace"
  default     = "demo-logicapp-testing"
}

variable "servicebus_resource_group" {
  description = "The resource group name of the service bus namespace"
  default     = "Blog_LogicApp_Testing"
}

variable "functions_name" {
  description = "The name of the function app"
  default     = "blog-ms-la-helpers"
}

variable "functions_resource_group" {
  description = "The resource group name of the function app is"
  default     = "Platform_Functions"
}







