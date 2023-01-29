
#TODO: Change this
# Add your logic app resource group name here
$myResourceGroup = "LogicApp_ResourceGroup"

function ReplaceParameterValue($logicAppParameter, $newValue){
    if($logicAppParameter -ne $null){
        $logicAppParameter.defaultValue = $newValue
    }    
}

function DownloadLogicAppJson([string] $resourceGroup, [string] $logicAppName, [string] $fileName){
    
    Write-Host 'Downloading Logic App'
    Write-Host 'Resource Group:' $resourceGroup
    Write-Host 'Logic App: ' $logicApp
    Write-Host 'Output File: ' $fileName

    $logicApp = Get-AzLogicApp -ResourceGroup $resourceGroup -Name $logicAppName
    $logicAppText = $logicApp.Definition.ToString()
    
    #Common Regex Replacements
    $logicAppText = $logicAppText -replace '/resourceGroups/Mikes-RG/', '/resourceGroups/${logicAppResourceGroupName}/'    
    $logicAppText = $logicAppText -replace 'Mikes-SubId', '${subscription_id}'
    $logicAppText = $logicAppText -replace '/resourceGroups/Mikes-APIM-RG/', '/resourceGroups/${apimResourceGroupName}/'    
    $logicAppText = $logicAppText -replace '/resourceGroups/Mikes-Functions-RG/', '/resourceGroups/${functionsResourceGroupName}/'    
    $logicAppText = $logicAppText -replace '/Microsoft.ApiManagement/service/Mikes-APIM/', '/Microsoft.ApiManagement/service/${apimInstanceName}/'    
    $logicAppText = $logicAppText -replace '/sites/mikes-function-app/functions/', '/sites/${helperFunctionAppsName}/functions/'  
        
    
    #Parameter Replacements in Logic App Definitions
    $logicAppDefinition = $logicAppText | ConvertFrom-Json
    ReplaceParameterValue -logicAppParameter $logicAppDefinition.parameters.aad_tenant_id -newValue '${aad_tenant_id}'
        
    $logicAppText = $logicAppDefinition | ConvertTo-Json -Depth 100
        

    # Write out the workflow definition to a file
    $logicAppText | Out-File -FilePath .\$fileName    

    Write-Host "Logic App Download Complete"
}

DownloadLogicAppJson -logicAppName "Demo-LogicApp-1" -fileName 'Res.LogicApp.Demo-LogicApp-1.json' -resourceGroup $myResourceGroup 
DownloadLogicAppJson -logicAppName "Demo-LogicApp-2" -fileName 'Res.LogicApp.Demo-LogicApp-2.json' -resourceGroup $myResourceGroup 




