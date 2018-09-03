$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "TempDB Configuration" -Tags TempDbConfiguration, $filename {
    @(Get-Instance).ForEach{
        Context "Testing TempDB Configuration on $psitem" {
            $TempDBTest = Test-DbaTempDbConfiguration -SqlServer $psitem
            It "should have TF1118 enabled on $($TempDBTest[0].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDb1118) {
                $TempDBTest[0].CurrentSetting | Should -Be $TempDBTest[0].Recommended -Because 'TF 1118 should be enabled'
            }
            It "should have $($TempDBTest[1].Recommended) TempDB Files on $($TempDBTest[1].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.tempdbfileCount) {
                $TempDBTest[1].CurrentSetting | Should -Be $TempDBTest[1].Recommended -Because 'This is the recommended number of tempdb files for your server'
            }
            It "should not have TempDB Files autogrowth set to percent on $($TempDBTest[2].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
                $TempDBTest[2].CurrentSetting | Should -Be $TempDBTest[2].Recommended -Because 'Auto growth type should not be percent'
            }
            It "should not have TempDB Files on the C Drive on $($TempDBTest[3].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
                $TempDBTest[3].CurrentSetting | Should -Be $TempDBTest[3].Recommended -Because 'You dot want the tempdb files on the same drive as the operating system'
            }
            It "should not have TempDB Files with MaxSize Set on $($TempDBTest[4].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileSizeMax) {
                $TempDBTest[4].CurrentSetting | Should -Be $TempDBTest[4].Recommended -Because 'Tempdb files should be able to grow'
            }
        }
    }
}

Describe "Dedicated Administrator Connection" -Tags Security, DAC, $filename {
    $dac = Get-DbcConfigValue policy.dacallowed
    @(Get-Instance).ForEach{
        Context "Testing Dedicated Administrator Connection on $psitem" {
            It "DAC is set to $dac on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1 | Should -Be $dac -Because 'This is the setting that you have chosen for DAC connections'
            }
        }
    }
}

Describe "Max Memory" -Tags MaxMemory, $filename {
    @(Get-Instance).ForEach{
        Context "Testing Max Memory on $psitem" {
            It "Max Memory setting Should Be correct on $psitem" {
                @(Test-DbaMaxMemory -SqlInstance $psitem).ForEach{
                    $psitem.SqlMaxMB | Should -BeLessThan ($psitem.RecommendedMB + 379) -Because 'You do not want to exhaust server memory'
                }
            }
        }
    }
}

Describe "BUILTIN\Administrators removed" -Tags Security, BuildInAdmins, $filename {
    @(Get-Instance).ForEach{
        Context "Checking that BUILTIN\Administrators login has been removed on $psitem" {
            $results = (Get-DbaLogin -SqlInstance $psitem -Login 'BUILTIN\Administrators')
            It "BUILTIN\Administrators login does not exist on $psitem" {
                $results | Should -Be $null -Because 'Removing the BUILTIN\Administrators account is a requirement'
            }
        }
    }
}

Describe "SA login disable" -Tags Security, SaDisabled, $filename {
    @(Get-Instance).ForEach{
        Context "Checking that sa login has been disabled on $psitem" {
            $results = (Get-DbaLogin -SqlInstance $psitem -Login sa).IsDisabled
            It "sa login has been disabled on $psitem" {
                $results | Should -Be $true -Because 'Disabling the sa account is a requirement'
            }
        }
    }
}

Describe "OLE Automation" -Tags Security, OLEAutomation, $filename {
    $OLEAutomation = Get-DbcConfigValue policy.oleautomation
    @(Get-Instance).ForEach{
        Context "Testing OLE Automation on $psitem" {
            It "OLE Automation is set to $OLEAutomation on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'OleAutomationProceduresEnabled').ConfiguredValue -eq 1 | Should -Be $OLEAutomation -Because 'OLE Automation can introduce additional security risks'
            }
        }
    }
}

Describe "Model Database Growth" -Tags ModelDbGrowth, $filename {
    $modeldbgrowthtest = Get-DbcConfigValue skip.instance.modeldbgrowth
    if (-not $modeldbgrowthtest) {
        @(Get-Instance).ForEach{
            Context "Testing model database growth setting is not default on $psitem" {
                @(Get-DbaDatabaseFile -SqlInstance $psitem -Database Model).ForEach{
                    It "Model database growth settings should not be percent for file $($psitem.LogicalName) on $($psitem.SqlInstance)" {
                        $psitem.GrowthType | Should -Not -Be 'Percent' -Because 'New databases use the model database as a template and percent growth can cause performance problems'
                    }
                    It "Model database growth settings should not be 1Mb for file $($psitem.LogicalName) on $($psitem.SqlInstance)" {
                        $psitem.Growth | Should -Not -Be 1024 -Because 'New databases use the model database as a template and growing for each Mb will have a performance impact'
                    }
                }
            }
        }
    }
}


Describe "Number of error log files" -Tags ErrorLog, $filename {
    @(Get-Instance).ForEach{
        Context "Checking Number of errorlog files on $psitem" {
            It "Number of error log files on $psitem should be 30" {
               (Connect-dbaInstance -SqlInstance $psitem).NumberOfLogFiles | Should -Be 30 -Because "This is a agreed default"

            }
        }
    }
}

Describe "Port number" -Tags PortNumber, $filename {
    @(Get-Instance).ForEach{
        Context "Checking port number on $psitem" {
            $port = (Get-DbaTcpPort -SqlInstance $psitem).Port
            It "Port number on $psitem should not be 1433 but between 1434 - 1450" {
               $port | Should -Not -Be 1433 -Because "This is a known default port"
               $port | Should -BeGreaterThan 1434 -Because "This is an allowed port range"
               $port | Should -BeLessThan 1451 -Because "This is an allowed port range"
            }
        }
    }
}

