[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$teamcityModule = Import-Module $PSScriptRoot\Private\teamcity.psm1 -DisableNameChecking -PassThru


Get-ChildItem "$PSScriptRoot\Private\" -Filter *.ps1 -Recurse |
    ForEach {
      . $_.FullName
    }


Get-ChildItem "$PSScriptRoot\Public\" -Filter *.ps1 -Recurse |
    ForEach {
      . $_.FullName
      Export-ModuleMember -Function $_.BaseName
    }

Write-Verbose 'RedGate.Build is installing its dependencies using paket...' -verbose
Install-PaketPackages
Show-PaketPackages | Write-Verbose -verbose

# Store the path to nuget.exe.
$NugetExe = Resolve-Path "$_PackagesDir\Nuget.CommandLine\tools\nuget.exe"

# Export all the functions from the Teamcity module
Get-Command -Module $teamcityModule -CommandType Function | Export-ModuleMember

# Always export all aliases.
Export-ModuleMember -Alias *

Export-ModuleMember -Variable NugetExe

# For debug purposes, uncomment this to export all functions of this module.
# Export-ModuleMember -Function *
