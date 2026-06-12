[CmdletBinding()]
param()

& (Join-Path $PSScriptRoot 'Test-Privacy.ps1')
