<#
.SYNOPSIS
  Execute NUnit tests from a single assembly
.DESCRIPTION
  1. Install required Nuget Packages to get nunit-console.exe and dotcover.exe
  2. Use nunit-console.exe and dotcover.exe to execute NUnit tests with dotcover coverage
.EXAMPLE
  Invoke-NUnitForAssembly -AssemblyPath .\bin\debug\test.dll -NUnitVersion '2.6.2' -IncludedCategories 'working'
    Execute the NUnit tests from test.dll using nunit 2.6.2 (nuget package will be installed if need be.).
    And pass '/include:working' to nunit-console.exe
.EXAMPLE
  Invoke-NUnitForAssembly -AssemblyPath .\bin\debug\test.dll -EnableCodeCoverage
    Execute the NUnit tests from test.dll and wrap nunit-console.exe with dotcover.exe to provide code coverage.
    Code coverage report will be saved as .\bin\debug\test.dll.coverage.snap
.NOTES
  See also: Merge-CoverageReports
#>
function Invoke-NUnitForAssembly {
  [CmdletBinding()]
  param(
    # The path of the assembly to execute tests from
    [Parameter(Mandatory=$true)]
    [string] $AssemblyPath,
    # The version of the nuget package containing the NUnit executables (NUnit.Runners)
    [string] $NUnitVersion = $DefaultNUnitVersion,
    # Whether to use nunit x86 or nunit x64 (default)
    [switch] $x86,
    # A list of excluded test categories
    [string[]] $ExcludedCategories = @(),
    # A list of incuded test categories
    [string[]] $IncludedCategories = @(),
    # If set, enable code coverage using dotcover
    [bool] $EnableCodeCoverage = $false,
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $DotCoverVersion = $DefaultDotCoverVersion,
    # The dotcover filters passed to dotcover.exe
    [string] $DotCoverFilters = '',
    # If set, do not import test results automatically to Teamcity.
    # In this case it is the responsibility of the caller to call 'TeamCity-ImportNUnitReport "$AssemblyPath.TestResult.xml"'
    [switch] $DotNotImportResultsToTeamcity
  )

  $AssemblyPath = Resolve-Path $AssemblyPath

  Write-Output "Executing tests from $AssemblyPath. (code coverage enabled: $EnableCodeCoverage)"

  try {

    $NunitArguments = Build-NUnitCommandLineArguments `
      -AssemblyPath $AssemblyPath `
      -ExcludedCategories $ExcludedCategories `
      -IncludedCategories $IncludedCategories

    $NunitExecutable = Get-NUnitConsoleExePath -NUnitVersion $NUnitVersion -x86:$x86.IsPresent

    if( $EnableCodeCoverage ) {

      Invoke-DotCoverForExecutable `
        -TargetExecutable $NunitExecutable `
        -TargetArguments $NunitArguments `
        -OutputFile "$AssemblyPath.coverage.snap" `
        -DotCoverVersion $DotCoverVersion `
        -DotCoverFilters $DotCoverFilters

    } else {

      Execute-Command {
        & $NunitExecutable $NunitArguments
      }

    }

  } finally {
    if(-not $DotNotImportResultsToTeamcity.IsPresent) {
      TeamCity-ImportNUnitReport "$AssemblyPath.TestResult.xml"
    }
  }

}
