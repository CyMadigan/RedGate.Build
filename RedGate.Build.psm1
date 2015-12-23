[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$teamcityModule = Import-Module $PSScriptRoot\Private\teamcity.psm1 -DisableNameChecking -PassThru

"$PSScriptRoot\Private\" |
    Resolve-Path |
    Get-ChildItem -Filter *.ps1 -Recurse |
    ForEach {
      . $_.FullName
    }

"$PSScriptRoot\Public\" |
    Resolve-Path |
    Get-ChildItem -Filter *.ps1 -Recurse |
    ForEach {
      . $_.FullName
      Export-ModuleMember -Function $_.BaseName
    }



if ($Host.Name -ne "Default Host") {
  Write-Host "RedGate.Build is using its own nuget.exe. Version $((Get-Item $nugetExe).VersionInfo.FileVersion)"
}

# Export all the functions from the Teamcity module
Get-Command -Module $teamcityModule -CommandType Function | Export-ModuleMember

# Always export all aliases.
Export-ModuleMember -Alias *

# For debug purposes, uncomment this to export all functions of this module.
# Export-ModuleMember -Function *
