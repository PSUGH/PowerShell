##########################################
## Install AppInstaller/WinGet on WS 2022
##########################################

Get-Command -Name winget

## Install prerequisite: VCLibs
Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
Add-AppxPackage -Path 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
Add-AppxProvisionedPackage -Online -PackagePath 'Microsoft.VCLibs.x64.14.00.Desktop.appx' -SkipLicense 

## Install prerequisite: UIXaml 
## https://apps.microsoft.com/store/detail/appinstaller/9NBLGGH4NNS1
## $downloadURI = 'http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/cadae296-3389-40c2-b927-605f7b399b78?P1=1694714835&P2=404&P3=2&P4=RmUW%2f%2fVjuzjWAvjotyJ%2fQvY%2by4ENBcIQZMBz%2b%2bO1N4hkvijd96SzmDW89QHeM9vAthAFCdFiU%2bO%2f1D%2fdOk6CSA%3d%3d'
## Invoke-WebRequest -UseBasicParsing -Uri $downloadURI -OutFile 'Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.appx'
## Add-AppxPackage -Path 'Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.appx'
## Add-AppxProvisionedPackage -Online -PackagePath 'Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.appx' -SkipLicense

## Install prerequisite: UIXaml (via nuget.org)
Invoke-WebRequest -Uri 'https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3' -OutFile 'microsoft.ui.xaml.2.7.3.zip'
Expand-Archive -Path 'microsoft.ui.xaml.2.7.3.zip' -DestinationPath 'microsoft.ui.xaml.2.7.3' 
$appxFile = '.\microsoft.ui.xaml.2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx'
Add-AppxPackage -Path $appxFile
Add-AppxProvisionedPackage -Online -PackagePath $appxFile -SkipLicense

## Get Winget-MSIX bundle from Github
$baseUri = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
foreach ($uri in (Invoke-RestMethod -uri $baseUri).assets.browser_download_url ) {
    $uri | Write-Host -ForegroundColor Yellow
    Invoke-RestMethod -UseBasicParsing -Uri $uri -OutFile $uri.Split('/')[-1]
}

## Install MSIX
$msix = Get-ChildItem -Filter 'Microsoft.DesktopAppInstaller*.msixbundle'
$license = Get-ChildItem -Filter '*License1.xml'
Add-AppProvisionedPackage -Online -PackagePath $msix -LicensePath $license


## Test setup
Test-Path -Path "$home\AppData\Local\Microsoft\WindowsApps\Winget.exe"
Get-Command -Name winget
Get-AppxPackage -Name 'Microsoft.UI.Xaml*'  | Select-Object -Property Name,Version ## Microsoft.UI.Xaml.2.7 7.2208.15002.0
Get-AppxPackage -Name 'Microsoft.VCLibs*' | Select-Object -Property Name,Version ## Microsoft.UI.Xaml.2.7 7.2208.15002.0

## Fix encoding issues in PowerShell ISE
whoami ; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

## Use WinGet
winget --info 
winget search powershell 
winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements