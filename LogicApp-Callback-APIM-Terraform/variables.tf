
variable "logicapp_consumption_resource_group" {
  description = "The name of the resource group for logic apps"
  default     = "LogicApp_RG"
}



variable "logicapp_standard_resource_group" {
  description = "The name of the resource group for logic apps"
  default     = ""
}

variable "logicapp_standard_app_name" {
  description = "The name of the logic app standard app"
  default     = ""
}

variable "apim_resource_group" {
  description = "The name of the resource group for APIM"
  default     = "APIM_RG"
}

variable "apim_name" {
  description = "The name of the APIM instance"
  default     = "my-apim"
}