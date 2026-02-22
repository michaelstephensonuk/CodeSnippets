param(
  [Parameter(Mandatory=$true)]
  [string]$AppName,
  
  [Parameter(Mandatory=$true)]
  [string]$EnvironmentName,
  
  [Parameter(Mandatory=$true)]
  [string]$RedirectUrl,
  
  [Parameter(Mandatory=$false)]
  [string[]]$GroupObjectIds,
  
  [Parameter(Mandatory=$false)]
  [int]$SecretExpiryYears = 2
)

$displayName = "$AppName-$EnvironmentName"

Write-Host ""
Write-Host "Creating App Registration: $displayName" -ForegroundColor Cyan

# 1. Create App Registration
az ad app create --display-name $displayName --sign-in-audience "AzureADMyOrg" --web-redirect-uris $RedirectUrl --enable-id-token-issuance true --enable-access-token-issuance true --output none

# 2. Get the App ID and Object ID
$appId = az ad app list --display-name $displayName --query "[0].appId" -o tsv
$appObjectId = az ad app list --display-name $displayName --query "[0].id" -o tsv

if (-not $appId) {
  Write-Host "Error: Failed to create App Registration" -ForegroundColor Red
  exit 1
}

Write-Host "App Registration created with ID: $appId" -ForegroundColor Cyan

# 3. Add Group Claims to Token Configuration
Write-Host "Adding Group Claims (Security Groups)..." -ForegroundColor Cyan
az ad app update --id $appId --set groupMembershipClaims=SecurityGroup

# 4. Add Optional Claims for groups in ID and Access tokens
Write-Host "Adding Optional Claims for groups..." -ForegroundColor Cyan

$optionalClaimsBody = @{
  optionalClaims = @{
    idToken = @(
      @{
        name = "groups"
        source = $null
        essential = $false
        additionalProperties = @()
      }
    )
    accessToken = @(
      @{
        name = "groups"
        source = $null
        essential = $false
        additionalProperties = @()
      }
    )
    saml2Token = @()
  }
} | ConvertTo-Json -Depth 10

$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempFile -Value $optionalClaimsBody -Encoding UTF8

$uri = "https://graph.microsoft.com/v1.0/applications/$appObjectId"
az rest --method PATCH --uri $uri --headers "Content-Type=application/json" --body "@$tempFile" --output none

Remove-Item -Path $tempFile -Force

Write-Host "Optional Claims added successfully" -ForegroundColor Green

# 5. Create Enterprise App (Service Principal)
Write-Host "Creating Enterprise App (Service Principal)..." -ForegroundColor Cyan
az ad sp create --id $appId --output none

# 6. Get Service Principal ID
$spId = az ad sp list --filter "appId eq '$appId'" --query "[0].id" -o tsv

# 7. Enable User Assignment Required
Write-Host "Enabling User Assignment Required..." -ForegroundColor Cyan
az ad sp update --id $spId --set appRoleAssignmentRequired=true

# 8. Assign Groups to Enterprise App
if ($GroupObjectIds -and $GroupObjectIds.Count -gt 0) {
  Write-Host "Assigning Groups to Enterprise App..." -ForegroundColor Cyan
  
  $defaultAppRoleId = "00000000-0000-0000-0000-000000000000"
  
  foreach ($groupId in $GroupObjectIds) {
    Write-Host "  Assigning group: $groupId" -ForegroundColor Cyan
    
    $tempFile = [System.IO.Path]::GetTempFileName()
    $jsonBody = @{
      principalId = $groupId
      resourceId = $spId
      appRoleId = $defaultAppRoleId
    } | ConvertTo-Json
    
    Set-Content -Path $tempFile -Value $jsonBody -Encoding UTF8
    
    $uri = "https://graph.microsoft.com/v1.0/groups/$groupId/appRoleAssignments"
    
    az rest --method POST --uri $uri --headers "Content-Type=application/json" --body "@$tempFile" --output none 2>$null
    
    $success = $LASTEXITCODE -eq 0
    
    Remove-Item -Path $tempFile -Force
    
    if ($success) {
      Write-Host "  Group $groupId assigned successfully" -ForegroundColor Green
    }
    else {
      Write-Host "  Warning: Failed to assign group $groupId" -ForegroundColor Yellow
    }
  }
}

# 9. Create Client Secret
Write-Host "Creating Client Secret..." -ForegroundColor Cyan
$secretJson = az ad app credential reset --id $appId --append --display-name "BicepDeployment-$EnvironmentName" --years $SecretExpiryYears --output json
$secretOutput = $secretJson | ConvertFrom-Json
$clientSecret = $secretOutput.password

# Output
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "App Registration Created Successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Display Name:        $displayName" -ForegroundColor Cyan
Write-Host "App Object ID:       $appObjectId" -ForegroundColor Cyan
Write-Host "Service Principal:   $spId" -ForegroundColor Cyan
Write-Host ""
Write-Host "Group Claims Config:" -ForegroundColor Cyan
Write-Host "  - groupMembershipClaims: SecurityGroup" -ForegroundColor Cyan
Write-Host "  - Optional Claims: groups (ID Token + Access Token)" -ForegroundColor Cyan
Write-Host ""
Write-Host "--------------------------------------------" -ForegroundColor Yellow
Write-Host "CLIENT ID:           $appId" -ForegroundColor Yellow
Write-Host "CLIENT SECRET:       $clientSecret" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Yellow
Write-Host ""

if ($GroupObjectIds -and $GroupObjectIds.Count -gt 0) {
  Write-Host "Assigned Groups:" -ForegroundColor Cyan
  foreach ($groupId in $GroupObjectIds) {
    $groupName = az ad group show --group $groupId --query displayName -o tsv 2>$null
    if ($groupName) {
      Write-Host "  - $groupName ($groupId)" -ForegroundColor Cyan
    }
    else {
      Write-Host "  - $groupId" -ForegroundColor Cyan
    }
  }
  Write-Host ""
}

Write-Host "Bicep Parameters:" -ForegroundColor Magenta
Write-Host ""
Write-Host "  authClientId = `"$appId`""
Write-Host "  authClientSecret = `"$clientSecret`""
Write-Host ""
Write-Host "============================================" -ForegroundColor Green

return [PSCustomObject]@{
  DisplayName        = $displayName
  ClientId           = $appId
  ClientSecret       = $clientSecret
  AppObjectId        = $appObjectId
  ServicePrincipalId = $spId
  AssignedGroups     = $GroupObjectIds
}
