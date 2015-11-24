#requires -Version 2

<#
    .SYNOPSIS
    Obtains a NuGet package version based on the build version number and branch name.

    .DESCRIPTION
    Obtains a NuGet package version based on a 4-digit build version number, the branch name and whether or not the branch is the default branch.

    .OUTPUT
    A NuGet version string based on the input parameters. The string is also suitable for use as an assembly's AssemblyInformationalVersion attribute value.

    .EXAMPLE
    Get-NuGetPackageVersion -Version '1.2.3.4' -BranchName 'master' -IsDefaultBranch $True

    Returns '1.2.3.4'. This shows how this cmdlet might be invoked on the default master branch with a four digit version number.

    .EXAMPLE
    Get-NuGetPackageVersion -Version '1.2.3.4' -BranchName 'SomeBranch' -IsDefaultBranch $False

    Returns '1.2.3-SomeBranch4'. This shows how this cmdlet might be invoked on a feature branch, resulting in a pre-release version string.
#>
function Get-NuGetPackageVersion 
{
    [CmdletBinding()]
    param(
        <#
            .PARAMETER Version
            A four digit version number of the form Major.Minor.Patch.Revision.
        #>
        [Parameter(Mandatory = $true)]
        [version] $Version,

        <#
            .PARAMETER BranchName
            The name of the current source control branch. e.g. 'master' or 'my-feature'. This is only used when IsDefaultBranch is false, in order to determine the pre-release version suffix. If the branch name is too long, this cmdlet will try to shorten it to satisfy the 20 character limit for the pre-release suffix. Nonetheless, you should try to avoid long branch names.
        #>
        [Parameter(Mandatory = $true)]
        [string] $BranchName,

        <#
            .PARAMETER IsDefaultBranch
            Indicates whether or not BranchName represents the default branch for the source control system currently in use. Please note that this is not a switch parameter - you must specify this value explicitly.
        #>
        [Parameter(Mandatory = $true)]
        [bool] $IsDefaultBranch
    )

    # If this is the default branch, there's no pre-release suffix. Just return the version number.
    if ($IsDefaultBranch)
    {
        return [string]$Version
    }
    elseif (-not $BranchName)
    {
        throw 'BranchName must be specified when IsDefaultBranch is false'
    }

    # Otherwise establish the pre-release suffix from the branch name.
    $PreReleaseSuffix = "-$BranchName"

    # Remove invalid characters from the suffix.
    $PreReleaseSuffix = $PreReleaseSuffix -replace '[^0-9A-Za-z-]', ''

    # Shorten the suffix if necessary, to satisfy NuGet's 20 character limit.
    $Revision = [string]$Version.Revision
    $MaxLength = 20 - $Revision.Length
    if ($PreReleaseSuffix.Length -gt $MaxLength) 
    {
        $PreReleaseSuffix = $PreReleaseSuffix -replace '[aeiou]', ''

        # If the suffix is still too long after we've stripped out the vovels, truncate it.
        if ($PreReleaseSuffix.Length -gt $MaxLength) 
        {
            $PreReleaseSuffix = $PreReleaseSuffix.Substring(0, $MaxLength)
        }
    }

    # And finally compose the full NuGet package version.
    $Major = $Version.Major
    $Minor = $Version.Minor
    $Patch = $Version.Build
    return "$Major.$Minor.$Patch$PreReleaseSuffix$Revision"
}
