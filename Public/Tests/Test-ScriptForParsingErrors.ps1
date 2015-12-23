<#
.SYNOPSIS
    Test a powershell script for parsing errors

.DESCRIPTION
    Parse a powershell script (without executing it) and throws parsing exceptions if any

.EXAMPLE
    Test-ScriptForParsingErrors -Path C:\myscript.ps1
    Will parse C:\myscript.ps1 and throw exceptions if parsing errors are encountered.

.EXAMPLE
    'C:\myscript.ps1' | Test-ScriptForParsingErrors
    Will parse C:\myscript.ps1 and throw exceptions if parsing errors are encountered.

.EXAMPLE
    dir '*.ps1' | Test-ScriptForParsingErrors
    Will parse every powershell script in the current folder and throw exceptions if parsing errors are encountered.

.LINK
    To other relevant cmdlets or help
#>
Function Test-ScriptForParsingErrors
{
    [CmdletBinding()]
    [OutputType([Nullable])]
    Param
    (
        # The Path to the powershell script that will be tested
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)]
        [String] $Path
    )
    Begin
    {
        $local:ErrorActionPreference = 'Stop'
    }
    Process
    {
        Write-Verbose "Parsing $Path to check for parsing error"
        $ExecutionContext.InvokeCommand.NewScriptBlock((Get-Content -Path $Path | Out-String)) | Out-Null
        Write-Verbose "Parsing $Path - All good!"
    }
}
