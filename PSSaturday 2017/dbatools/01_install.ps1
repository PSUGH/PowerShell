##install online
Install-Module dbatools

##install offline
Invoke-WebRequest https://dbatools.io/zip -Outfile dbatools.zip
Expand-Archive dbatools.zip -DestinationPath .
Import-Module .\dbatools-master\dbatools.psd1

##overview
Get-Command -Module dbatools

(Get-Command -Module dbatools -CommandType Function).count
