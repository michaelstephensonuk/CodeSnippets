

variable "logicapp_resource_group_name" {
  description = "The name of the resource group for the logic app"
  default     = ""
}

variable "logicapp_name" {
  description = "The name of the logic app"
  default     = ""
}

variable "workflow_name" {
  description = "The name of the workflow within the logic app"
  default     = ""
}

variable "workflow_trigger_name" {
  description = "The name of the workflow trigger within the logic app"
  default     = ""
}


variable "apim_resource_group_name" {
  description = "The name of the resource group for the apim"
  default     = ""
}

variable "apim_name" {
  description = "The name of the name for the apim instance"
  default     = ""
}

variable "apim_api_name" {
  description = "The name of the name for the api within apim"
  default     = ""
}