<#
.SYNOPSIS
    Set the value of the OutputPath properties in a VS project file

.DESCRIPTION
    Open the project file, abd overwrite the value of any OutputPath property
    Note that this does not support setting different OutputPath depending
    on PropertyGroup condition.

    bin\$(Configuration) is probably a decent default
#>
function Set-ProjectOutputPaths {
    [CmdletBinding()]
    param(
        # The path to a .csproj or .vbproj file. (msbuild format)
        [string] $ProjectFile,

        # The value of the OutputPath property to be set
        [string] $Value
    )

    # Crude parameter checking
    $ProjectFile = Resolve-Path $ProjectFile

    $xml = [xml](Get-Content $ProjectFile)

    $xml.Project.PropertyGroup | where OutputPath | ForEach {
        if($_.OutputPath -ne $Value) {
            Write-Verbose "Project: $ProfileFile. Updating OutputPath from '$($_.OutputPath)' to '$Value'" -verbose
            $fileWasUpdated = $true
            $_.OutputPath = $Value
        }
    }

    if($fileWasUpdated) {
        $xml.Save($ProjectFile)
    }
}
