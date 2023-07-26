

variable "resource_group_name" {
  description = "The name of the resource group"
  default     = ""
}

variable "resource_group_location" {
  description = "The location of the resource group"
  default     = ""
}

variable "resource_name" {
  description = "The name of the resource"
  default     = ""
}

variable "resource_id" {
  description = "The id of the resource"
  default     = ""
}

variable "private_endpoint_subnet_id" {
  description = "The subnet id of the storage account"
  default     = ""
}

variable "sub_resource_name" {
  description = "The name of the sub resource eg, queue, blob"
  default     = ""
}

variable "dns_c_name_zone_name" {
  description = "The name of the dns zone for the cname"
  default     = ""
}

variable "dns_a_record_zone_name" {
  description = "The name of the dns zone for the a record"
  default     = ""
}

variable "host_name" {
  description = "The host name to setup the private endpoint for"
  default     = ""
}

variable "c_name_record" {
  description = "The name for the cname record"
  default     = ""
}






variable "default_tags" {
    type = map
    default = {        
          
    }
}