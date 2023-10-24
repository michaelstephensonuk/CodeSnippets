# Used By:
# - Developer wanting to deploy on local machine

# Overview:
# This script is intended to perform a local deployment of the code from the logic app
# folder to your azure dev environment in azure
# it is to handle the scenario where you would do the equivelent in a pipeline but it needs more
# than just right click deploy

# Note:
# this is ONLY intended to be ran on your development machine



Param(
        [Parameter()]
        [bool]$runAcceptanceTests = $false
)

$logicAppName = '{Your-Value-Here}'
$resourceGroupName = '{Your-Value-Here}'
$solutionName = '{Your-Value-Here}'

# Import Helper Functions
. "$PSScriptRoot\LogicApp.Deployment.Local.Helpers.ps1"

$logicAppTempDeploymentDirectory = 'c:\Temp\LogicApp\TempDeploymentDirectory'

$currentDirectory = $PSScriptRoot
Set-Location $currentDirectory

# Do a build on the whole solution
Write-Host 'Started - Build Solution' -ForegroundColor DarkBlue

Set-Location ..
dotnet build $solutionName

Write-Host 'Complete - Build Solution' -ForegroundColor Green

# Copy the logic app folder to a temp directory for the deployment
Write-Host 'Started - Copying Logic App to Temp Directory' -ForegroundColor DarkBlue
$fromDirectory = 'LogicApp'
$toDirectory = $logicAppTempDeploymentDirectory + '\LogicApp'


if ((Test-Path $logicAppTempDeploymentDirectory) ) {
    Write-Host 'A previous deployment temp folder exists'
    Remove-Item -Path $logicAppTempDeploymentDirectory -Force -Recurse
}
Copy-Item $fromDirectory -Filter * -Destination $toDirectory -Recurse
Write-Host 'Complete - Copying Logic App to Temp Directory' -ForegroundColor Green

# Manipulate the connections to flip them from key to managed identity that they need in the cloud
Write-Host 'Started - Changing connections.json to managed identity' -ForegroundColor DarkBlue

$connectionsFilePath = $toDirectory + '\connections.json'
Convert-Connections-To-ManagedIdentity -connectionsFilePath $connectionsFilePath

Write-Host 'Complete - Changing connections.json to managed identity' -ForegroundColor Green

# Remove files we do not need
Write-Host 'Started - Remove files not needed in the package' -ForegroundColor DarkBlue

$pathToDelete = $toDirectory + '\global.json'
Remove-Item -Path $pathToDelete -Force

$pathToDelete = $toDirectory + '\local.settings.json'
Remove-Item -Path $pathToDelete -Force

$pathToDelete = $toDirectory + '\workflow-designtime'
Remove-Item -Path $pathToDelete -Force -Recurse

$pathToDelete = $toDirectory + '\.vscode'
Remove-Item -Path $pathToDelete -Force -Recurse

$pathToDelete = $toDirectory + '\.debug'
Remove-Item -Path $pathToDelete -Force -Recurse

Write-Host 'Complete - Remove files not needed in the package' -ForegroundColor Green

# Zip the deployment folder so it can be deployed
Write-Host 'Started - Zipping Code ready for deployment' -ForegroundColor DarkBlue
$targetZipFile = $logicAppTempDeploymentDirectory + '\LogicApp.zip'
Compress-Archive -Path $toDirectory\* -DestinationPath $targetZipFile

if ((Test-Path $targetZipFile) -eq $false ) {
    Write-Host 'ERROR: The target zip file path does not exist' -ForegroundColor Red
    exit
}
Write-Host 'Created Zip File: ' $targetZipFile

Write-Host 'Complete - Zipping Code ready for deployment' -ForegroundColor Green

# Perform the deployment
Write-Host 'Started - Performing Logic App Deployment' -ForegroundColor DarkBlue

Write-Host 'Resource Group: ' $resourceGroupName
Write-Host 'Logic App: ' $logicAppName
Write-Host 'Deploying File: ' $targetZipFile

Publish-AzWebapp -ResourceGroupName $resourceGroupName -Name $logicAppName -ArchivePath $targetZipFile
Write-Host 'Complete - Performing Logic App Deployment' -ForegroundColor Green


# Execute Tests
Write-Host 'Started - Acceptance Tests' -ForegroundColor DarkBlue
if($runAcceptanceTests -eq $true){
    $testLocation = '..\AcceptanceTests'
    
    Set-Location $testLocation

    dotnet test --logger:"console;verbosity=normal"
}
else {
    Write-Host 'Acceptance tests flag is false so skipping' -ForegroundColor Yellow
}

Write-Host 'Complete - Acceptance Tests' -ForegroundColor Green
