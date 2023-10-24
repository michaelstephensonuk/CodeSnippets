# Used By:
# - Local development when running the LogicApp.Deployment.Local.ps1 script

# Overview:
# The aim of this script is to be ran locally on your dev machine to convert connections
# to managed identity before deploying them to azure

# Note:
# this is ONLY intended to be ran on your development machine




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

function Convert-Connections-To-ManagedIdentity {
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$connectionsFilePath
    )

    Write-Host 'Connections.json path: ' $connectionsFilePath

    # Check the connections.json exists and log
    if ((Test-Path $connectionsFilePath) ) {
        Write-Host 'The connections file exists'
    }
    else{
        Write-Warning 'The connections file DOES NOT exist'
        exit
    }

    # Load the connections.json file to memory so we can manipulate it
    Write-Host 'Reading connections.json'
    $connectionsJson = Get-Content -Path $connectionsFilePath -Raw | ConvertFrom-Json

    # Convert the connections to managed identity
    # We will iterate over the managedApiConnections and if the type is key we will change it 
    # to managed identity and remove the scheme and parameter types
    Write-Host 'Convert the connections to managed identity'
    foreach($connectionProperty in $connectionsJson.managedApiConnections.PSObject.Properties.Value){        
        Write-Host 'Processing Connection: ' $connectionProperty.PSObject.Properties.Key

        if($connectionProperty.authentication.type -eq 'Raw'){
            Write-Host '    Connection uses authentication type = Raw'

            $connectionProperty.authentication.type = "ManagedServiceIdentity"

            $connectionProperty.authentication.PSObject.Properties.Remove('scheme')
            $connectionProperty.authentication.PSObject.Properties.Remove('parameter')
            
            Write-Host '    Connection changed to managed identity'
        }
        else{
            Write-Host '    Connection DOES NOT use authentication type = Raw'
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
                        | Set-Content -Path $connectionsFilePath -Force
}



