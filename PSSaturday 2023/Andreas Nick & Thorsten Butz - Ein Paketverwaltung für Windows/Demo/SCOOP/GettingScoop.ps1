#######################################################
## Getting scoop
## Set-ExecutionPolicy RemoteSigned -Scope CurrentUser 
## irm get.scoop.sh | iex
#######################################################

Set-Location -Path 'C:\pssat\SCOOP'
Invoke-RestMethod -Uri 'get.scoop.sh'  | Out-File -FilePath 'scoop.ps1'
psedit -filenames scoop.ps1
.\scoop.ps1

scoop bucket list
scoop search firefox
scoop search youtube-dl
scoop install youtube-dl  ## Legal issues

scoop search yt-dlp
scoop install yt-dlp
Get-Command -Name yt-dlp

scoop install firefox ## Error: "Couldn't find manifest for 'firefox'."
scoop bucket add extras ## Requires (already installed) git

scoop search pwsh
scoop install 'pwsh@7.0.3'
scoop install --help

