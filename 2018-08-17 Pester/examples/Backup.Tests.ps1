$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Last Full Backup Times" -Tags LastFullBackup, LastBackup, Backup, DISA, $filename {
    $maxfull = Get-DbcConfigValue policy.backup.fullmaxdays
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        Context "Testing last full backups on $psitem" {
            @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ ($psitem.Name -ne 'tempdb') -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                $offline = ($psitem.Status -match "Offline")
                It -Skip:$offline "$($psitem.Name) full backups on $($psitem.Parent.Name) Should Be less than $maxfull days" {
                    $psitem.LastBackupDate | Should -BeGreaterThan (Get-Date).AddDays( - ($maxfull)) -Because "Taking regular backups is extraordinarily important"
                }
            }
        }
    }
}

Describe "Last Log Backup Times" -Tags LastLogBackup, LastBackup, Backup, DISA, $filename {
    $maxlog = Get-DbcConfigValue policy.backup.logmaxminutes
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        Context "Testing last log backups on $psitem" {
            @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ (-not $psitem.IsSystemObject) -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                if ($psitem.RecoveryModel -ne "Simple") {
                    $offline = ($psitem.Status -match "Offline")
                    It -Skip:$offline "$($psitem.Name) log backups on $($psitem.Parent.Name) Should Be less than $maxlog minutes" {
                        $psitem.LastLogBackupDate | Should -BeGreaterThan (Get-Date).AddMinutes( - ($maxlog) + 1) -Because "Taking regular backups is extraordinarily important"
                    }
                }

            }
        }
    }
}