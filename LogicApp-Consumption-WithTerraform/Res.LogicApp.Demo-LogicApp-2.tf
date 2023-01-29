data "local_file" "logicapp_demo2_definition" {
  filename = "Res.LogicApp.Demo-LogicApp-2.json"
}

data "template_file" "logicapp_demo2_definition" {
    template = data.local_file.logicapp_demo2_definition.content
    vars = merge(
                tomap({
                    
                }))                
}

resource "azapi_resource" "logicapp_demo2" {
    type                = "Microsoft.Logic/workflows@2019-05-01"
    name                = "Demo-LogicApp-2"

    location            = azurerm_resource_group.logicapps.location
    parent_id           = azurerm_resource_group.logicapps.id
    
    identity {
        type  = "UserAssigned"
        identity_ids = [ azurerm_user_assigned_identity.logicapps.id ]
    }

    tags = merge(
                tomap({
                    #Note this forces the logic app to be updated every time we run deploy
                    "DeploymentTime" = timestamp(),
                }), 
                local.logicapp_default_tags)

    body = jsonencode({
        properties = {
            definition = jsondecode(data.template_file.logicapp_demo2_definition.rendered)            
            parameters = {
                               
            }
        }
    })
}
