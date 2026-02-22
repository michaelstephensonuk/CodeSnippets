@description('Environment name (e.g., dev, test, prod)')
param environmentName string

@description('Name prefix for all resources')
param appName string

@description('Name of the existing App Service Plan')
param existingAppServicePlanName string

// Add parameter for the resource group containing the App Service Plan
@description('Resource group containing the existing App Service Plan')
param existingAppServicePlanResourceGroup string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Azure AD App Registration Client ID for Easy Auth')
param authClientId string

@secure()
@description('Azure AD App Registration Client Secret for Easy Auth')
param authClientSecret string

@description('List of allowed tenant IDs for authentication (comma-separated or array)')
param allowedTenantIds array

@description('List of allowed tenant IDs for authentication (comma-separated or array)')
param allowedGroups array




// Name variables
var logAnalyticsWorkspaceName = '${appName}-law-${environmentName}'
var appInsightsName = '${appName}-appi-${environmentName}'
var webAppName = '${appName}-web-${environmentName}'
var userAssignedIdentityName = '${appName}-id-${environmentName}'

// User Assigned Managed Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
}

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1 // Set your desired daily cap in GB
    }
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
  }
}

// Reference existing App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: existingAppServicePlanName
  scope: resourceGroup(existingAppServicePlanResourceGroup)
}



// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    keyVaultReferenceIdentity: userAssignedIdentity.id
    siteConfig: {
      netFrameworkVersion: 'v9.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      use32BitWorkerProcess: false
      appSettings: [               

        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }        
        {
          name: 'AZURE_CLIENT_ID'
          value: userAssignedIdentity.properties.clientId
        }        
        {
          name: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'          
          value: authClientSecret
        }
        {
          name: 'WEBSITE_AUTH_AAD_ALLOWED_TENANTS'
          value: allowedTenantIds != [] ? join(allowedTenantIds, ',') : ''
        }        
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
        
      ]
      connectionStrings: [
        
      ]
    }
  }
}

// Web App Authentication (Easy Auth) Configuration
resource webAppAuth 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'authsettingsV2'
  properties: {
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          // Use specific tenant instead of /common/ to restrict to your tenant only
          openIdIssuer: 'https://login.microsoftonline.com/${allowedTenantIds[0]}/v2.0'
          clientId: authClientId
          clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
        }
        validation: {          
          allowedAudiences: [
            'api://${authClientId}'
            authClientId  // Also allow the raw client ID as audience
          ]          
          defaultAuthorizationPolicy: { 
            allowedPrincipals: {
              groups: allowedGroups      
            }
            // Restrict to only this application's client ID
            allowedApplications: [
              authClientId
            ]                               
          }
        }
        isAutoProvisioned: false
      }
    }
    login: {
      tokenStore: {
        enabled: true
      }
    }
  }
}

