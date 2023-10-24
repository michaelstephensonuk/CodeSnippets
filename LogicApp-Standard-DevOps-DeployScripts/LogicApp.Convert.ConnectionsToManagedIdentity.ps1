# Used By:
# - Azure DevOps Pipeline

# Overview:
# The aim of this script is to be ran in the azure devops pipeline
# it will manipulate the connections.json file so that the managed api connections are changed from 
# using the key to managed identity
# vscode does this automatically when doing the deployment from vscode but when we do this in a pipeline
# we will need to do this outselves

# Note:
# this is not intended to be ran on your development machine


$scriptDirectory = $PSScriptRoot
$logicAppConnectionsInputPath = $scriptDirectory + '\..\LogicApp\connections.json'
$logicAppConnectionsArchivePath = $scriptDirectory + '\..\LogicApp\connections.archive.json'

# Note this is configurable so that when we are developing the scipt its easy to use a temp path
$logicAppConnectionsOutputPath = $scriptDirectory + '\..\LogicApp\connections.json' 


function Format-Json {
    <#
    .SYNOPSIS
        Prettifies JSON output.
    .DESCRIPTION
        Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    .PARAMETER Json
        Required: [string] The JSON text to prettify.
    .PARAMETER Minify
        Optional: Returns the json string compressed.
    .PARAMETER Indentation
        Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
        Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .EXAMPLE
        $json | ConvertTo-Json  | Format-Json -Indentation 2
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(ParameterSetName = 'Minify')]
        [switch]$Minify,

        [Parameter(ParameterSetName = 'Prettify')]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,

        [Parameter(ParameterSetName = 'Prettify')]
        [switch]$AsArray
    )

    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
    }

    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
        ForEach-Object {
            # If the line contains a ] or } character, 
            # we need to decrement the indentation level unless it is inside quotes.
            if ($_ -match "[}\]]$regexUnlessQuoted") {

                [int[]] $indentArray = ($indent - $Indentation),0

                if ($indentArray[0] -gt $indentArray[1]) { 
                    $indent = $indentArray[0] 
                    }
                else { 
                    $indent = 0
                    }
            }

            # Replace all colon-space combinations by ": " unless it is inside quotes.
            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')

            # If the line contains a [ or { character, 
            # we need to increment the indentation level unless it is inside quotes.
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation
            }

            $line
        }

    if ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}

Write-Host 'Input - Connections.json path: ' $logicAppConnectionsInputPath
Write-Host 'Archive - Connections.json path: ' $logicAppConnectionsArchivePath


# Check the connections.json exists and log
if ((Test-Path $logicAppConnectionsInputPath) ) {
    Write-Host 'The connections file exists'
}
else{
    Write-Warning 'The connections file DOES NOT exist'
    exit
}

# Archive the connections.json file so we can restore if things go wrong
Write-Host 'Backing up connections.json'
Copy-Item $logicAppConnectionsInputPath $logicAppConnectionsArchivePath

# Load the connections.json file to memory so we can manipulate it
Write-Host 'Reading connections.json'
$connectionsJson = Get-Content -Path $logicAppConnectionsInputPath -Raw | ConvertFrom-Json

# Convert the connections to managed identity
# We will iterate over the managedApiConnections and if the type is key we will change it 
# to managed identity and remove the scheme and parameter types
Write-Host 'Convert the connections to managed identity'
foreach($connectionProperty in $connectionsJson.managedApiConnections.PSObject.Properties.Value){
    Write-Host 'Processing Connection: ' $connectionsJson.managedApiConnections.PSObject.Properties.Key

    if($connectionProperty.authentication.type -eq 'Raw'){
        Write-Host 'Connection uses authentication type = Raw'

        $connectionProperty.authentication.type = "ManagedServiceIdentity"

        $connectionProperty.authentication.PSObject.Properties.Remove('scheme')
        $connectionProperty.authentication.PSObject.Properties.Remove('parameter')
        
        Write-Host 'Connection changed to managed identity'
    }
    else{
        Write-Host 'Connection DOES NOT use authentication type = Raw'
    }
}

# Write the json object back to the output file, note we are using a custom format json function to 
# make the json more readable
# Link to page with pretty json https://stackoverflow.com/questions/56322993/proper-formating-of-json-using-powershell/56324939
# Note the regex is used to handle the case of not escaping single quotes
Write-Host "Writing the json back to the connections output file"
$connectionsJson | ConvertTo-Json -Depth 100 `
                    | Format-Json `
                    | % { [System.Text.RegularExpressions.Regex]::Unescape($_) } `
                    | Set-Content -Path $logicAppConnectionsOutputPath -Force
