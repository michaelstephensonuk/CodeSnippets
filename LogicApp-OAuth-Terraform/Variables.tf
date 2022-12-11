##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)



variable "apim_resource_group" {
  description = "The name of the resource group for APIM"
  default     = "Blog_APIM_and_Frontdoor"
}

variable "apim_name" {
  description = "The name of the APIM instance"
  default     = "ms-blog-apim"
}

variable "apim_keyvault_name" {
  description = "The name of the Key Vault instance"
  default     = "ms-blog-keyvault"
}

variable "aad_object_prefix" {
  description = "The prefix we will add to the service principals and app registrations"
  default     = "APIM-Sec-POC"
}



