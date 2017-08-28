# Don't run everything, thanks @alexandair!
break

# Set some vars
$ins1 = 'Server1'
$ins2 = 'Server2'
$allservers = $ins1, $ins2

$samples = 'D:\samples\'
$share = '\\Server1\share'

# Prepare the instances
Restore-DbaDatabase -SqlInstance $ins1 -Path $samples'adventureworks.bak'
Get-DbaDatabase -SqlInstance $ins1 | FT

# all-in-one
Get-ChildItem  $samples -Filter *.bak | Restore-DbaDatabase -SqlInstance $ins1 -WithReplace
Get-DbaDatabase -SqlInstance $ins1 -NoSystemDb | FT

# correct RecoveryModel
Set-DbaDatabaseState -SqlInstance $ins1 -AllDatabases
Set-DbaDatabaseOwner -SqlInstance $ins1 -TargetLogin 'sa'

# let's do some sanity checks
$allservers | Get-DbaLastBackup | FT
$checkdbs = Get-DbaLastGoodCheckDb -SqlInstance $ins1
$checkdbs
$checkdbs | Where-Object LastGoodCheckDb -eq $null | FT
$checkdbs | Where-Object LastGoodCheckDb -lt (Get-Date).AddDays(-1)

$diskspace = Get-DbaDiskSpace -SqlInstance $allservers -Detailed
$diskspace | Where-Object PercentFree -lt 10

# manual migration with rename
Get-ChildItem -Path $share -Include *.bak -File -Recurse | ForEach-Object { $_.Delete() }
Backup-DbaDatabase -SqlInstance $ins1 -Databases 'AdventureWorks' -Type Full -BackupDirectory $share
Restore-DbaDatabase -SqlServer $ins2 -Path $share -DatabaseName 'new_AdventureWorks' -DestinationFilePrefix 'new_' -WithReplace -UseDestinationDefaultDirectories
Repair-DbaOrphanUser -SqlInstance $ins2
