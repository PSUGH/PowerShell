function Get-DiskInfo {
Get-CimInstance -ClassName win32_volume | Where-Object { $_.DriveType -eq 3 -and $_.Label -ne 'System' } | Sort-Object Name
}

$filename = $MyInvocation.MyCommand.Name.Replace('.Tests.ps1', '')

Describe 'Get-DiskAlloc' -Tag Alloc, $filename {
    foreach ($disk in Get-DiskInfo) {


        It "does check for disk allocation unit size for: $($disk.Name)" {
            $disk.BlockSize | Should Be 65536
        }
    }

}

Describe 'Get-DiskStatus' -Tag OperationalStatus, $filename {
    foreach ($disk in Get-Disk) {
        It "disk number $($disk.Number) should have OperationalStatus = Online" {
            $disk.OperationalStatus | Should Be 'Online'
            }
    }
}

Describe 'Get-DiskFreeSpace' -Tag DiskFree, $filename {
    $MinDiskFree = 10
    foreach ($disk in Get-DiskInfo) {
         $DiskFree = [math]::round((($disk.FreeSpace / $disk.Capacity) * 100), 2)
         It "$($disk.Name) should have > $MinDiskFree% available" {
                    $DiskFree | Should -BeGreaterOrEqual $MinDiskFree
                }
    }
}