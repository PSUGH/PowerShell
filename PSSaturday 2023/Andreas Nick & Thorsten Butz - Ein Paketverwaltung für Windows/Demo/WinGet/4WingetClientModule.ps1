#############################################
## Microsoft.WinGet.Client Powershell module
#############################################

## Current issue:
## "Winget Powershell Modules do not run on Windows PowerShell (5.1)"
## https://github.com/microsoft/winget-cli/issues/2881

Find-Module -Name *WinGet*
Install-Module -Name 'Microsoft.WinGet.Client' -Scope CurrentUser
Get-Module -Name  'Microsoft.WinGet.Client' -ListAvailable
Import-Module -Name 'Microsoft.WinGet.Client' 

Get-Command -Module 'Microsoft.WinGet.Client' 

## Administrative settings 
Enable-WinGetSetting -name LocalManifestFiles
Enable-WinGetSetting -name BypassCertificatePinningForMicrosoftStore
Enable-WinGetSetting -name InstallerHashOverride
Enable-WinGetSetting -name LocalArchiveMalwareScanOverride
(Get-WinGetSettings | ConvertFrom-Json).adminSettings

## "Front-end settings"
## https://aka.ms/winget-settings
## https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md

## Search & Install
Get-WinGetSource # winget source list
Get-WinGetPackage -Moniker vscode

winget search --tag browser
Find-WinGetPackage -Name vivaldi -Source winget | Select-Object -First 1 | Install-WinGetPackage -Scope User
Find-WinGetPackage -Tag Browser  -Source winget | Out-GridView -PassThru | Install-WinGetPackage -Scope User