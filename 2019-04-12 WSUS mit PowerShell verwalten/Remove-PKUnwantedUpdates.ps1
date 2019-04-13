Import-Module -Name PoshWSUS

Connect-PSWSUSServer -WsusServer wsus16bs -Port 8530

$Updates = Get-PSWSUSUpdate -IncludeText 'Preview'

foreach ($Update in $Updates)
{
  # "Removing Update ""$($Update.Title)"""
  $Update.LegacyName
  $Update.LegacyName -match '^(KB[0-9]*)' | Out-Null
  $KB = $Matches[1]
  $KB
  Remove-PSWSUSUpdate -Update $KB
}
