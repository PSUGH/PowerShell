$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Valid Database Owner" -Tags ValidDatabaseOwner, $filename {
    [string[]]$targetowner = Get-DbcConfigValue policy.validdbowner.name
    [string[]]$exclude = Get-DbcConfigValue policy.validdbowner.excludedb
    @(Get-Instance).ForEach{
        Context "Testing Database Owners on $psitem" {
            @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.Name -notin $exclude -and ($ExcludedDatabases -notcontains $_.Name)}).ForEach{
                It "Database $($psitem.Name) - owner $($psitem.Owner) should be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.Parent.Name)" {
                    $psitem.Owner | Should -BeIn $TargetOwner -Because "The account that is the database owner is not what was expected"
                }
            }
        }
    }
}

Describe "Recovery Model" -Tags RecoveryModel, DISA, $filename {
    @(Get-Instance).ForEach{
        $recoverymodel = Get-DbcConfigValue policy.recoverymodel.type
        Context "Testing Recovery Model on $psitem" {
            $exclude = Get-DbcConfigValue policy.recoverymodel.excludedb
            $exclude += $ExcludedDatabases 
            @(Get-DbaDbRecoveryModel -SqlInstance $psitem -ExcludeDatabase $exclude).ForEach{
                It "$($psitem.Name) should be set to $recoverymodel on $($psitem.SqlInstance)" {
                    $psitem.RecoveryModel | Should -Be $recoverymodel -Because "You expect this recovery model"
                }
            }
        }
    }
}

Describe "Page Verify" -Tags PageVerify, $filename {
    $pageverify = Get-DbcConfigValue policy.pageverify
    @(Get-Instance).ForEach{
        Context "Testing page verify on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                It "$($psitem.Name) on $($psitem.Parent.Name) should have page verify set to $pageverify" {
                    $psitem.PageVerify | Should -Be $pageverify -Because "Page verify helps SQL Server to detect corruption"
                }
            }
        }
    }
}

Describe "Auto Close" -Tags AutoClose, $filename {
    $autoclose = Get-DbcConfigValue policy.database.autoclose
    @(Get-Instance).ForEach{
        Context "Testing Auto Close on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Close set to $autoclose" {
                    $psitem.AutoClose | Should -Be $autoclose -Because "Because!"
                }
            }
        }
    }
}

Describe "Auto Shrink" -Tags AutoShrink, $filename {
    $autoshrink = Get-DbcConfigValue policy.database.autoshrink
    @(Get-Instance).ForEach{
        Context "Testing Auto Shrink on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Shrink set to $autoshrink" {
                    $psitem.AutoShrink | Should -Be $autoshrink -Because "Shrinking databases causes fragmentation and performance issues"
                }
            }
        }
    }
}

Describe "Auto Create Statistics" -Tags AutoCreateStatistics, $filename {
    $autocreatestatistics = Get-DbcConfigValue policy.database.autocreatestatistics
    @(Get-Instance).ForEach{
        Context "Testing Auto Create Statistics on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Create Statistics set to $autocreatestatistics" {
                    $psitem.AutoCreateStatisticsEnabled | Should -Be $autocreatestatistics -Because "This is value expeceted for autocreate statistics"
                }
            }
        }
    }
}

Describe "Auto Update Statistics" -Tags AutoUpdateStatistics, $filename {
    $autoupdatestatistics = Get-DbcConfigValue policy.database.autoupdatestatistics
    @(Get-Instance).ForEach{
        Context "Testing Auto Update Statistics on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Update Statistics set to $autoupdatestatistics" {
                    $psitem.AutoUpdateStatisticsEnabled | Should -Be $autoupdatestatistics  -Because "This is value expeceted for autoupdate statistics"
                }
            }
        }
    }
}

Describe "Auto Update Statistics Asynchronously" -Tags AutoUpdateStatisticsAsynchronously, $filename {
    $autoupdatestatisticsasynchronously = Get-DbcConfigValue policy.database.autoupdatestatisticsasynchronously
    @(Get-Instance).ForEach{
        Context "Testing Auto Update Statistics Asynchronously on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Update Statistics Asynchronously set to $autoupdatestatisticsasynchronously" {
                    $psitem.AutoUpdateStatisticsAsync | Should -Be $autoupdatestatisticsasynchronously  -Because "This is value expeceted for autoupdate statistics asynchronously"
                }
            }
        }
    }
}

Describe "Database Orphaned User" -Tags OrphanedUser, $filename {
    @(Get-Instance).ForEach{
        Context "Testing database orphaned user event on $psitem" {
            $results = Get-DbaOrphanUser -SqlInstance $psitem
            It "$psitem should return 0 orphaned users" {
                @($results).Count | Should -Be 0 -Because "We dont want orphaned users"
            }
        }
    }
}

Describe "Compatibility Level" -Tags CompatibilityLevel, $filename {
    @(Get-Instance).ForEach{
        Context "Testing database compatibility level matches server compatibility level on $psitem" {
            @(Test-DbaDatabaseCompatibility -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases).ForEach{
                It "$($psitem.Database) has a database compatibility level equal to the level of $($psitem.SqlInstance)" {
                    $psItem.DatabaseCompatibility | Should -Be $psItem.ServerLevel -Because "it means you are on the appropriate compatibility level for your SQL Server version to use all available features"
                }
            }
        }
    }
}

Describe "Datafile Auto Growth Configuration" -Tags DatafileAutoGrowthType, $filename {
    $datafilegrowthtype = Get-DbcConfigValue policy.database.filegrowthtype
    $datafilegrowthvalue = Get-DbcConfigValue policy.database.filegrowthvalue
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    $exclude += $ExcludedDatabases 
    @(Get-Instance).ForEach{
        Context "Testing datafile growth type on $psitem" {
            @(Get-DbaDatabaseFile -SqlInstance $psitem -ExcludeDatabase $exclude ).ForEach{
                if (-Not (($psitem.Growth -eq 0) -and (Get-DbcConfigValue skip.database.filegrowthdisabled))) {
                    It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have GrowthType set to $datafilegrowthtype on $($psitem.SqlInstance)" {
                        $psitem.GrowthType | Should -Be $datafilegrowthtype -Because "We expect a certain file growth type"
                    }
                    if ($datafilegrowthtype -eq "kb") {
                        It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have Growth set equal or higher than $datafilegrowthvalue on $($psitem.SqlInstance)" {
                            $psitem.Growth * 8 | Should -BeGreaterOrEqual $datafilegrowthvalue  -because "We expect a certain file growth value"
                        }
                    }
                    else {
                        It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have Growth set equal or higher than $datafilegrowthvalue on $($psitem.SqlInstance)" {
                            $psitem.Growth | Should -BeGreaterOrEqual $datafilegrowthvalue  -because "We expect a certain fFile growth value"
                        }
                    }
                }
            }
        }
    }
}

Describe "Logfile Auto Growth Configuration" -Tags LogfileAutoGrowthType, $filename {
    $logfilegrowthtype = Get-DbcConfigValue policy.database.filegrowthtype
    $logfilegrowthvalue = Get-DbcConfigValue policy.database.filegrowthvalue
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    $exclude += $ExcludedDatabases 
    @(Get-Instance).ForEach{
        Context "Testing logfile growth type on $psitem" {
            @((Get-DbaDatabaseFile -SqlInstance $psitem -ExcludeDatabase $exclude ).Where{$_.Type -eq 1 }).ForEach{
                if (-Not (($psitem.Growth -eq 0) -and (Get-DbcConfigValue skip.database.filegrowthdisabled))) {
                    It "$($psitem.LogicalName) should have GrowthType set to $logfilegrowthtype on $($psitem.SqlInstance)" {
                        $psitem.GrowthType | Should -Be $logfilegrowthtype -Because "Expected file growth type: $logfilegrowthtype"
                    }

                }
                if ($psitem.GrowthType -eq "kb") {
                        It "$($psitem.LogicalName) should have Growth set equal or higher than $logfilegrowthvalue on $($psitem.SqlInstance)" {
                            $psitem.Growth | Should -BeGreaterOrEqual $logfilegrowthvalue  -because "Expected file growth value of: $logfilegrowthvalue"
                        }
                }

            }
        }
    }
}