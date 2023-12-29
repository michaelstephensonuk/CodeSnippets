

variable "deployment_name" {
  description = "The name of the arm deployment"
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the resource group"
  default     = ""
}

variable "connection_name" {
  description = "The name of the api connection"
  default     = ""
}

variable "connection_location" {
  description = "The location of the api connection"
  default     = ""
}

variable "sql_server" {
  description = "The name of the server"
  default     = ""
}

variable "sql_database" {
  description = "The name of the database"
  default     = ""
}

variable "sql_username" {
  description = "The database username"
  default     = ""
}

variable "sql_password" {
  description = "The database password"
  default     = ""
}

variable "sql_encryptConnection" {
  description = "Encrypt Connection"
  default     = "false"
}

variable "sql_privacySetting" {
  description = "The privacy setting for the connection"
  default     = "None"
}

variable "sql_sqlConnectionString" {
  description = "The connection string for the database"
  default     = ""
}



