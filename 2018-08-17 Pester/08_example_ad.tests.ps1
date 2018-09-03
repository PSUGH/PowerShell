#requires -version 5.0
#requires -Module ActiveDirectory, DNSClient
 
 
<#
 
Use Pester to test Active Directory
 
#>
 
 
$myDomain = Get-ADDomain
$DomainControllers = $myDomain.ReplicaDirectoryServers
$GlobalCatalogServers = (Get-ADForest).GlobalCatalogs
 
Write-output "Testing Domain $($myDomain.Name)"
Foreach ($DC in $DomainControllers) {
 
    Describe $DC {
 
        Context Network {
            It "Should respond to a ping" {
                Test-Connection -ComputerName $DC -Count 2 -Quiet | Should Be $True
            }
 
            #ports
            $ports = 53,389,445,5985,9389
            foreach ($port in $ports) {
                It "Port $port should be open" {
                #timeout is 2 seconds
                [system.net.sockets.tcpclient]::new().ConnectAsync($DC,$port).Wait(2000) | Should Be $True
                }
            }
 
            #test for GC if necessary
            if ($GlobalCatalogServers -contains $DC) {
                It "Should be a global catalog server" {
                    [system.net.sockets.tcpclient]::new().ConnectAsync($DC,3268).Wait(2000) | Should Be $True
                }
            }
            
            #DNS name should resolve to same number of domain controllers
            It "should resolve the domain name" {
             (Resolve-DnsName -Name globomantics.local -DnsOnly -NoHostsFile | Measure-Object).Count | Should Be $DomainControllers.count
            }
        } #context
    
        Context Services {
            $services = "ADWS","DNS","Netlogon","KDC"
            foreach ($service in $services) {
                It "$Service service should be running" {
                    (Get-Service -Name $Service -ComputerName $DC).Status | Should Be 'Running'
                }
            }
 
        } #services
 
        Context Disk {
            $disk = Get-WmiObject -Class Win32_logicaldisk -filter "DeviceID='c:'" -ComputerName $DC
            It "Should have at least 20% free space on C:" {
                ($disk.freespace/$disk.size)*100 | Should BeGreaterThan 20
            }
            $log = Get-WmiObject -Class win32_nteventlogfile -filter "logfilename = 'security'" -ComputerName $DC
            It "Should have at least 10% free space in Security log" {
                ($log.filesize/$log.maxfilesize)*100 | Should BeLessThan 90
            }
        }
    } #describe
 
} #foreach
 
Describe "Active Directory" {
 
    It "Domain Admins should have 5 members" {
        (Get-ADGroupMember -Identity "Domain Admins" | Measure-Object).Count | Should Be 5
    }
    
    It "Enterprise Admins should have 1 member" {
        (Get-ADGroupMember -Identity "Enterprise Admins" | Measure-Object).Count | Should Be 1
    }
 
    It "The Administrator account should be enabled" {
        (Get-ADUser -Identity Administrator).Enabled | Should Be $True
    }
 
    It "The PDC emulator should be $($myDomain.PDCEmulator)" {
      (Get-WMIObject -Class Win32_ComputerSystem -ComputerName $myDomain.PDCEmulator).Roles -contains "Primary_Domain_Controller" | Should Be $True
    }
}