##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

# Variables which will be updated when the cookie cutter template created the solution



# General Variables for the EAI Environment 
variable "general_prefix_lowercase" {
  description = "The name of the environment"
  default     = "msdemo"
}

variable "environment_name" {
  description = "The name of the environment"
  default     = "Dev"
}

variable "main_resource_group" {
  description = "The name of the resource group"
  default     = ""
}

variable "keyvault_name" {
  description = "The name of the Key Vault instance"
  default     = ""
}

variable "keyvault_resource_group" {
  description = "The resource group name of the Key Vault instance"
  default     = ""
}


