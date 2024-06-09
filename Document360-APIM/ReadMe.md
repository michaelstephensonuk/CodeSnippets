This below sample yaml file is the tasks from my demo at the integrate summit where I show how to use an Azure DevOps pipeline to automate documentation updates from Azure APIM to Document360

The video for this is here

[<img src="https://i.ytimg.com/vi/Hc79sDi3f0U/maxresdefault.jpg" width="50%">]([https://www.youtube.com/watch?v=Hc79sDi3f0U](https://www.youtube.com/watch?v=EA-oT2zEiOA) "APIM Documentation in Document360")

The pipeline is

```
steps:
- task: Npm@1
  displayName: 'npm custom'
  inputs:
    command: custom
    verbose: false
    customCommand: 'install d360 -g'


- task: AzureCLI@2
  displayName: 'Download APIM Definition'
  inputs:
    azureSubscription: 'Turbo360_Demo_Platform'
    scriptType: ps
    scriptLocation: inlineScript
    inlineScript: |
     $rg = "platform"
     $apim = "kv-eai-apim"
     $path = "$(Build.ArtifactStagingDirectory)"
     
     $apiList = New-Object System.Collections.ArrayList
     $apiList.Add("external-api-booking-api")    
          
     ForEach ($api in $apiList ) {
     
     Write-Host 'Downloading API spec for:' $api
     
         az apim api export --api-id $api --ef OpenApiYamlFile --resource-group $rg --service-name $apim --file-path $path
     
     Write-Host 'API download complete:' $api
     
     }
     

#Your build pipeline references an undefined variable named ‘Doc360_API_Key’. Create or edit the build pipeline for this YAML file, define the variable on the Variables tab. See https://go.microsoft.com/fwlink/?linkid=865972
#Your build pipeline references an undefined variable named ‘Doc360_UserID’. Create or edit the build pipeline for this YAML file, define the variable on the Variables tab. See https://go.microsoft.com/fwlink/?linkid=865972

- powershell: |
   
   # Booking API
   $api = "external-api-booking-api"
   $file = "$(Build.ArtifactStagingDirectory)" + "\" + $api + "_openapi.yaml"
   
   Write-Host 'Uploading file: ' $file
   
   d360 apidocs:resync --apiReferenceId=40a9ad09-0c9a-43fa-8766-73e90d665bb2 --path=$file --apiKey=$(Doc360_API_Key) --userId=$(Doc360_UserID) --publish --force
   
   Write-Host 'Complete file: ' $file
   
  displayName: 'Upload Documentation to Doc360'

```
