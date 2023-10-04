#################################################################################################
## WinGET: Pinning
## https://learn.microsoft.com/en-us/windows/package-manager/winget/pinning
## https://github.com/microsoft/winget-pkgs/blob/master/manifests/m/Microsoft/PowerShell/7.1.5.0
## https://github.com/microsoft/winget-pkgs/blob/master/manifests/m/Microsoft/PowerToys/0.69.1
#################################################################################################

## PowerShell: Install specific version
winget install --id Microsoft.PowerShell --version 7.1.5.0
winget install --id Microsoft.PowerShell --version 7.2.2.0

## Block application (prevent updating)
winget pin add --id Microsoft.PowerShell --blocking --force

## PowerToys
winget search powertoys
winget install --id Microsoft.PowerToys --version 0.69.1
winget pin add --id Microsoft.PowerToys --blocking --force

## Show "pinned" apps
winget pin list
winget update 