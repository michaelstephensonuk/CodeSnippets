
#Brfore Start:
#1. Run Install-Module -Name Pester -Force -SkipPublisherCheck
#2. Update-Module -Name Pester
#3. Run Import-Module -Name Pester

#To Run Tests
#1. Run in current directory with CD
#2. Invoke-Pester ./LogicApp-Governance-Tests.ps1 -Output Diagnostics

#Note: Sometimes you might get an error about not recognizing the output switch.  If you just run it without the switch then run it again with it then it should work.
#It seems to be a multi version installed conflict

BeforeDiscovery {
    $armTemplateSchema = "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
    $armParametersTemplateSchema = "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#"
    
    $logicAppResourcetype = "MICROSOFT.LOGIC/WORKFLOWS"
    $apiConnectionResourceType = "MICROSOFT.WEB/CONNECTIONS"
    
    $rootDir = $PSScriptRoot  

    $filesToCheck = [System.Collections.ArrayList]::new();

    Write-Host "Root Directory: " $rootDir

    #Search for files recursively which might be json files to test
    $jsonFiles = Get-ChildItem -Path $rootDir -Filter *.json -Recurse | %{$_.FullName}
    $jsonFiles = Get-ChildItem -Path $rootDir -Filter *.json -Recurse -exclude "\debug\", "\Release\" | %{$_.FullName}
    foreach($file in $jsonFiles){
        if($file -match "\\debug\\"){
            continue
        }
        if($file -match "\\release\\"){
            continue
        }
        if($file -match "\\packages\\"){
            continue
        }

        Write-Host 'Adding file: ' $file

        $fileName = [System.IO.Path]::GetFileName($file)
        $fullPath = [System.IO.Path]::GetFileNameWithoutExtension($file)

        $fileToCheck = New-Object -TypeName psobject
        $fileToCheck | Add-Member -MemberType NoteProperty -Name 'FileName' -Value $fileName
        $fileToCheck | Add-Member -MemberType NoteProperty -Name 'FullPath' -Value $file
        $fileToCheck | Add-Member -MemberType NoteProperty -Name 'FileNameWithoutExtension' -Value $fullPath
        $filesToCheck.Add($fileToCheck)
    }

    Write-Host 'Before All Complete'
}

BeforeAll {
    $rootDir = $PSScriptRoot 
    $hardCodedSubscriptionId = "[Add subscription id here]"


    function CheckTagExists($tags, [string] $expectedTag){    
        $found = $false
        foreach($tag in $tags){
            $tagName = $tag.Name
            $tagJson = $tag.Value | ConvertTo-Json
        
            if($tagName -match $expectedTag){
                $found = $true
            }
        }

        return $found
    }
}

Describe "<_.FileName>" -ForEach $filesToCheck {
    BeforeDiscovery {
        $file = $_

        $content = Get-Content -Path $file.FullPath        

        $armTemplateFile = [System.Collections.ArrayList]::new();
        $armParameterFile = [System.Collections.ArrayList]::new();

        if($content -match $armTemplateSchema){            
            $armTemplateFile.Add($file)
        }

        if($content -match $armParametersTemplateSchema){            
            $armParameterFile.Add($file)
        }
    }

    
    Describe "ARM Template <_.name>" -ForEach $armTemplateFile {
        BeforeDiscovery {
            #Note we need to do this here so we can use the data driven discovery of dynamics tests within the processing of a dile

            $file = $_

            $content = Get-Content -Path $file.FullPath
            $armJson = $content | ConvertFrom-Json 
            
            Write-Host "Read file and converted to JSON"       

            $logicAppResources = [System.Collections.ArrayList]::new();
            $apiConnectionResources = [System.Collections.ArrayList]::new();

            foreach($resource in $armJson.resources){
                if($resource.type.ToUpper() -eq $logicAppResourcetype.ToUpper()){
                    Write-Host 'Adding Logic App: ' $resource.name
                    $logicAppResources.Add($resource)
                }

                if($resource.type.ToUpper() -eq $apiConnectionResourceType.ToUpper()){
                    Write-Host 'Adding API Connection: ' $resource.name
                    $apiConnectionResources.Add($resource)
                }
            }
        }

        BeforeAll {
            #Note we need to do this here so we have read the file for executing tests in this describe
            $file = $_

            $content = Get-Content -Path $file.FullPath
            $armJson = $content | ConvertFrom-Json
        }

        #If we have added connectors and not parameterized the subscription id this should catch it
        It "Does not contain more than expected no hard coded subscription id" {               
            $expectedNoHardCodedSubscriptionIds = 3
            $count = [regex]::matches($content, $hardCodedSubscriptionId).count
                  
            $count | Should -Be $expectedNoHardCodedSubscriptionIds
        }

        
        #Test Each Logic App
        Describe "<_.name>" -ForEach $logicAppResources {
            BeforeAll {                
                $logicApp = $_  
                $resourceTags = $_.tags.PSObject.Properties                          
            }        

            It "Resource Name meets the naming convention" {
                $expectedExpression = "LA-"

                Write-Host 'Testing Logic App Name: ' $logicApp.name
                $match = ($logicApp.name -match $expectedExpression)
                $match | Should -Be $true
            }

            It "Location is parameterized" {
                $expectedExpression = "\[parameters\("

                $match = ($logicApp.location -match $expectedExpression)
                $match | Should -Be $true
            }

            Context Tags{
                BeforeAll {                
                    $logicApp = $_  
                    $resourceTags = $_.tags.PSObject.Properties                          
                } 

                It "dataProfile tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "dataProfile"
                    $exists | Should -Be $true
                }

                It "Environment tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "Environment"
                    $exists | Should -Be $true
                }

                It "costCentre tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "costCentre"
                    $exists | Should -Be $true
                }

                It "managedBy tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "managedBy"
                    $exists | Should -Be $true
                }

                It "dataProfile tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "dataProfile"
                    $exists | Should -Be $true
                }

                It "scope tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "scope"
                    $exists | Should -Be $true
                }

                It "Project Name tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "Project Name"
                    $exists | Should -Be $true
                }

                It "interfaceCatalog:WorkItemID tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "interfaceCatalog:WorkItemID"
                    $exists | Should -Be $true
                }

                It "devops:ReleaseName tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devops:ReleaseName"
                    $exists | Should -Be $true
                }

                It "devops:ReleaseDefinition tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devops:ReleaseDefinition"
                    $exists | Should -Be $true
                }

                It "devOps:Repo tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devOps:Repo"
                    $exists | Should -Be $true
                }

                It "devOps:BuildDefinition tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devOps:BuildDefinition"
                    $exists | Should -Be $true
                }
            }
        
        }

        
        #Test Each API Connection
        Describe "<_.name>" -ForEach $apiConnectionResources {
            BeforeAll {                
                $apiConnection = $_                
            }        


            It "Resource Name is parameterized" {

                $expectedExpression = "\[parameters\("

                Write-Host 'Testing API Connection Name: ' $apiConnection.name
                $match = ($apiConnection.name -match $expectedExpression)
                $match | Should -Be $true
            }
        
            Context Tags{
                BeforeAll {                
                    $apiConnection = $_  
                    $resourceTags = $_.tags.PSObject.Properties                          
                } 

                It "dataProfile tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "dataProfile"
                    $exists | Should -Be $true
                }

                It "Environment tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "Environment"
                    $exists | Should -Be $true
                }

                It "costCentre tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "costCentre"
                    $exists | Should -Be $true
                }

                It "managedBy tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "managedBy"
                    $exists | Should -Be $true
                }

                It "dataProfile tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "dataProfile"
                    $exists | Should -Be $true
                }

                It "scope tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "scope"
                    $exists | Should -Be $true
                }

                It "Project Name tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "Project Name"
                    $exists | Should -Be $true
                }

                It "interfaceCatalog:WorkItemID tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "interfaceCatalog:WorkItemID"
                    $exists | Should -Be $true
                }

                It "devops:ReleaseName tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devops:ReleaseName"
                    $exists | Should -Be $true
                }

                It "devops:ReleaseDefinition tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devops:ReleaseDefinition"
                    $exists | Should -Be $true
                }

                It "devOps:Repo tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devOps:Repo"
                    $exists | Should -Be $true
                }

                It "devOps:BuildDefinition tag exists" {
                    $exists = CheckTagExists -tags $resourceTags -expectedTag "devOps:BuildDefinition"
                    $exists | Should -Be $true
                }
            }
        }
    }


    Describe "ARM Parameters <_.name>" -ForEach $armParameterFile {
        BeforeAll {
            $file = $_

            $content = Get-Content -Path $file.FullPath
            $armJson = $content | ConvertFrom-Json 
            
            Write-Host "Read file and converted to JSON"                   
        }
        
    }
}

