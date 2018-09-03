$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, StartName, $filename {
    @(Get-Instance).ForEach{
        Context "Testing SQL Engine Service on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem -Type Engine).ForEach{
                It "SQL Engine service account Should Be running on $($psitem.InstanceName)" {
                    $psitem.State | Should -Be "Running" -Because 'If the service is not running, the SQL Server will not be accessible'
                }
                It "SQL Engine service account should have a start mode of Automatic on $($psitem.InstanceName)" {
                    $psitem.StartMode | Should -Be "Automatic" -Because 'If the server restarts, the SQL Server will not be accessible'
                }
				It "SQL Engine service account should be an domain account on $($psitem.InstanceName) -> $($psitem.StartName)" {
                    $psitem.StartName | Should -Match $(((gwmi Win32_ComputerSystem).Domain).Split(".")[0]) -Because 'The SQL Server service has to run on a domain account'
                }
            }
        }
    }
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, StartName, $filename { 
    @(Get-ComputerName).ForEach{ 
        Context "Testing SQL Browser Service on $psitem" { 
            $Services = Get-DbaSqlService -ComputerName $psitem 
            
                It "SQL browser service on $psitem should be running to be able to resolve instance names" { 
                    $Services.Where{$_.ServiceType -eq 'Browser'}.State | Should -Be "Running" -Because 'If the service is not running no instance name can be resolved' 
                } 
                It "SQL browser service startmode Should Be Automatic on $psitem" { 
                    $Services.Where{$_.ServiceType -eq 'Browser'}.StartMode | Should -Be "Automatic" 
                }
                It "SQL browser service service account should be NT AUTHORITY\LOCALSERVICE on $psitem" {
                    $((Get-DbaSqlService -ComputerName $psitem -Type Browser).StartName) | Should -Match 'NT AUTHORITY\\LOCALSERVICE' -Because 'The SQL Server service has to run on ''NT AUTHORITY\LOCALSERVICE'''
                }
        }
    }
}

Describe "SQL Agent Account" -Tags AgentServiceAccount, ServiceAccount, StartName, $filename {
    @(Get-Instance).ForEach{
        Context "Testing SQL Agent is running on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem -Type Agent).ForEach{
                It "SQL Agent Should Be running on $($psitem.ServiceName)" {
                    $psitem.State | Should -Be "Running" -Because 'The agent service is required to run SQL Agent jobs'
                }
                It "SQL Agent service should have a start mode of Automatic on $($psitem.ServiceName)" {
                    $psitem.StartMode | Should -Be "Automatic" -Because 'Otherwise the Agent Jobs wont run if the server is restarted'
                }
                It "SQL Agent service account should be an domain account on $($psitem.ServiceName) -> $($psitem.StartName)" {
                    $psitem.StartName | Should -Match $(((gwmi Win32_ComputerSystem).Domain).Split(".")[0]) -Because 'The SQL Server service has to run on a domain account'
                }
            }
        }
    }
}