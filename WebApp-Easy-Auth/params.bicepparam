using './main.bicep'

param environmentName = 'dev'
param appName = 'mikes-app'
param location = 'northeurope'

//Existing App Service Plan details
param existingAppServicePlanName = 'mikes-app-service-plan'
param existingAppServicePlanResourceGroup = 'Platform_Hosting'

// Easy Auth Configuration
// App Reg Name = Mikes-App
param authClientId = 'TBC'
param authClientSecret = 'TBC'

// List of tenant IDs that are allowed to authenticate for Easy auth
param allowedTenantIds = [
  '99999999-9999-9999-9999-999999999999'  
]

param allowedGroups = [
  '99999999-9999-9999-9999-999999999999'  
]
