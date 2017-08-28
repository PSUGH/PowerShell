param([string]$path = $(throw "Path name must be specified."))
$state = Get-Content $path
Get-Service * `
  | Where-Object { $_.Status -eq "$state" } `
  | Select-Object Name, DisplayName, StartType `
  | Out-GridView -Title "Aktuell Dienste - Status: $state" 

