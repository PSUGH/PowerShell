$computer =
[pscustomobject]@{
Computername = $env:COMPUTERNAME
Services = @{Running ="DNS","KDC","NetLogon"},@{Stopped= "RemoteRegistry","Spooler"}
Features = @{Installed = "DNS","AD-Domain-Services"},@{NotInstalled = "SMTP-Server","Internet-Print-Client"}
Versions = @{PowerShell = 5; Windows = 2012}
}

foreach ($item in $computer) {
 
    Describe $($item.Computername) -Tags $item.Computername {
 
        $computername = $($item.Computername)
        $ps = New-PSSession -ComputerName $computername
        $cs = New-CimSession -ComputerName $computername
    
        It "Should be pingable" {
            Test-Connection -ComputerName $computername -Count 2 -Quiet | Should Be $True
        }
 
        It "Should respond to Test-WSMan" {
            {Test-WSMan -ComputerName $computername -ErrorAction Stop} | Should Not Throw
        }
 
    Context Features {
 
    $installed = Get-WindowsFeature -ComputerName $computername | Where Installed
    $Features = $($item.Features.Installed)  
    foreach ($feature in $features) {
 
       It "Should have $feature installed" {
            $installed.Name -contains $feature | Should Be $True
        }
    
    }
 
    $NotFeatures = $($item.features.notinstalled)
            foreach ($feature in $Notfeatures) {
 
               It "Should NOT have $feature installed"  {
                   $installed.Name -contains $feature | Should Be $False
                }
    
             }
    } #features
 
    Context Services  {
 
    $Stopped = $($item.services.Stopped)
    $Running = $($item.services.Running)
 
    $all = Invoke-Command { Get-Service } -session $ps
    foreach ($item in $Stopped) {
  
      It "Service $item should be stopped" {
        $all.where({$_.name -eq $item}).status | Should Be "Stopped"
      }
 
    }
 
    foreach ($item in $Running) {
  
      It "Service $item should be running" {
        $all.where({$_.name -eq $item}).status | Should Be "Running"
      }
 
    }
 
    } #services
 
    Context Versions {
        $winVer = $($item.versions.Windows)
        It "Should be running Windows Server $winVer" {
            (Get-CimInstance win32_operatingsystem -cimSession $cs).Caption | Should BeLike "*$winver*"
        }
 
        $psver = $($item.versions.powershell)
        It "Should be running PowerShell version $psver" {
            Invoke-Command { $PSVersionTable.psversion.major } -session $ps | Should be $psver
        }
    } #versions
 
    Context Other {
        It "Security event log should be at least 16MB in size" {
            ($cs | Get-CimInstance -ClassName win32_NTEVentlogFile -filter "LogFileName = 'Security'").FileSize | Should beGreaterThan 16MB
        }
        
        It "Should have C:\Temp folder" {
            Invoke-Command {Test-Path C:\Temp} -session $ps | Should Be $True
        }    
    } #other
 
    $ps | Remove-PSSession
    $cs | Remove-CimSession
 
    } #describe
 
} #foreach