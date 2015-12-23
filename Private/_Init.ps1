# _Init.ps1 is a script that can be used to initialise stuff when RedGate.Build is imported for the first time.
# (Like variables available within the module only.)

$ModuleDir = Resolve-Path "$PSScriptRoot\.."
# Create the packages folder where nuget packages used by this module will be installed.
$PackagesDir = New-Item -Path "$ModuleDir\packages" -ItemType Directory -Force

# Store the path to nuget.exe.
$NugetExe = Resolve-Path "$PSScriptRoot\nuget.exe"

$DefaultNUnitVersion = '2.6.4'
$DefaultDotCoverVersion = '3.2.0'
$DefaultSmartAssemblyVersion = '6.8.0.248'
