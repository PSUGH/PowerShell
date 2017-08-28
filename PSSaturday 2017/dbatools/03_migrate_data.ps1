# Don't run everything, thanks @alexandair!
break

# Set some vars
$ins1 = 'Server1'
$ins2 = 'Server2'
$allservers = $ins1, $ins2

$samples = 'D:\samples\'
$share = '\\Server1\share'

#now let's migrate some data
Start-DbaMigration -Source $ins1 -Destination $ins2 -BackupRestore -NetworkShare $share -WithReplace -NoSysDbUserObjects -Verbose
Sync-DbaSqlLoginPermission -Source $ins1 -Destination $ins2

# clean up
Find-DbaOrphanedFile -SqlInstance $ins2 -Verbose
Remove-DbaOrphanUser -SqlInstance $ins2 -WhatIf

# compare configs
$oldprops = Get-DbaSpConfigure -SqlInstance $ins1
$newprops = Get-DbaSpConfigure -SqlInstance $ins2

$propcompare = foreach ($prop in $oldprops) {
  [pscustomobject]@{
    Config = $prop.DisplayName
    'SQL Server 2014' = $prop.RunningValue
    'SQL Server 2016' = $newprops | Where-Object ConfigName -eq $prop.ConfigName | Select-Object -ExpandProperty RunningValue
  }
} 
$propcompare | Out-GridView 

# Copy-SqlSpConfigure
Copy-DbaSpConfigure -Source $ins1 -Destination $ins2 -Configs DefaultBackupCompression, IsSqlClrEnabled
