

resource "azurerm_function_app_function" "echo_helper_function" {
  name            = "echo-helper-function"
  function_app_id = data.azurerm_windows_function_app.helper_functions.id
  language        = "CSharp"

  file {
    name    = "run.csx"
    content = file("Res.Functions.Echo.Code.csx")
  }

  test_data = jsonencode({
    #Note this forces the resource to be updated every time we run deploy
    "DeploymentTime" = timestamp(),

    "name" = "Azure"
  })

  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}