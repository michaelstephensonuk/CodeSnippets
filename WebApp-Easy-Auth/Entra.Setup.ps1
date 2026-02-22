
# Run the below command to create the app registration and get the client ID and secret, then update the main.bicep file with those values before deploying the bicep template.
.\Create-AppRegistration.ps1 `
  -AppName "Mikes-App" `
  -EnvironmentName "Dev" `
  -RedirectUrl "https://mikes-app-dev.azurewebsites.net/.auth/login/aad/callback" `
  -GroupObjectIds @(
    "99999999-9999-9999-9999-999999999999"
  )
