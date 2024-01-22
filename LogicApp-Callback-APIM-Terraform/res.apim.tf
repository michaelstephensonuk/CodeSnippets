
#Create an API
resource "azurerm_api_management_api" "my_api" {
  name                = "logicapp-demo-api"
  resource_group_name = var.apim_resource_group
  api_management_name = var.apim_name
  revision            = "1"
  display_name        = "Demo API - LogicApp Proxy"
  path                = "demo/logicapps"
  protocols           = ["https"]      
  description         = <<-EOT
  This api will provide a demo of how to proxy both logic app consumption and standard
  
  EOT

}