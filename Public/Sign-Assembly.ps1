function Add-ToHashTableIfNotNull {
  param(
    [Parameter(Mandatory=$true)]
    [HashTable] $HashTable,
    [Parameter(Mandatory=$true)]
    [string] $Key,
    [string] $Value
  )

  if( $Value ) {
    $HashTable.Add($Key, $Value)
  }
}

<#
.SYNOPSIS
  Send an assembly to a webserver to be signed
.DESCRIPTION
  Send an assembly to a webserver to be digitally signed
#>
function Sign-Assembly {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $Server,

    [Parameter(Mandatory=$true)]
    [string] $AssemblyFilename,

    [string] $FileType = 'Exe',
    [string] $ReCompressZip,
    [string] $Certificate,
    [string] $Description,
    [string] $MoreInfoUrl
  )

  $Url = "http://$Server/Sign"

  $Headers = @{ 'FileType' =  $FileType };
  Add-ToHashTableIfNotNull $Headers -Key 'Certificate' -Value $Certificate
  Add-ToHashTableIfNotNull $Headers -Key 'Description' -Value $Description
  Add-ToHashTableIfNotNull $Headers -Key 'MoreInfoUrl' -Value $MoreInfoUrl
  Add-ToHashTableIfNotNull $Headers -Key 'ReCompressZip' -Value $ReCompressZip

  Invoke-WebRequest `
    -Uri $Url `
    -InFile $AssemblyFilename `
    -OutFile $AssemblyFilename `
    -Method Post `
    -ContentType 'binary/octet-stream' `
    -Headers $Headers

}
