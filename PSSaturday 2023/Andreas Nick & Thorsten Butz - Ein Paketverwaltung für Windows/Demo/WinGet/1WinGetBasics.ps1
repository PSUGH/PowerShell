##################
## WinGet: Basics
##################

## Fix encoding issues in ISE
whoami ; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

## Check AppExec alias
Get-Item -Path "$home\AppData\Local\Microsoft\WindowsApps\winget.exe"

## Get VSCode
winget search vscode
winget install --id  Microsoft.VisualStudioCode  --source winget --accept-package-agreements --accept-source-agreements