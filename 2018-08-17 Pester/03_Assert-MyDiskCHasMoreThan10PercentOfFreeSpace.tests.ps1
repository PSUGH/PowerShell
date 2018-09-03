function Assert-MyDiskCHasMoreThan10PercentOfFreeSpace {
    $diskInfo = Get-WmiObject win32_logicaldisk |
        where DeviceId -eq 'C:'

    $diskSize = $diskInfo.Size

    $expectedFreeSpace = $diskSize * 0.1  #10% of the total size
    $expectedFreeSpacelnGigabytes = [Math]::Round(
        $expectedFreeSpace / 1GB, 2)

    $freeSpace = $diskInfo.FreeSpace
    $freeSpaceInGigabytes = [Math]::Round($freeSpace / 1GB, 2)

    $freeSpaceInGigabytes |
        Should -BeGreaterThan $expectedFreeSpaceInGigabytes
}

# our check
Describe 'Disk health checks' {
    It 'Has at least 10% of free space' {
        Assert-MyDiskCHasMoreThan10PercentOfFreeSpace
    }
}

# our test for the check function
Describe "Assert-MyDiskCHasMoreThan10PercentOfFreeSpace" {
    It "Throws when I have 1% of free disk space" {
        Mock Get-WmiObject {
            [PSCustomObject] @{
                DeviceId = 'C:'
                Size = 100GB
                FreeSpace = 1GB 
            }
        }

        { Assert-MyDiskCHasMoreThan10PercentOfFreeSpace } |
            Should -Throw -ExpectedMessage 'Expected {1} to be greater than {10}'
    }

    It "Passes when I have 11% of free disk space" {
        Mock Get-WmiObject {
            [PSCustomObject] @{
                DeviceId = 'C:'
                Size = 100GB
                FreeSpace = 11GB
            }
        }

        Assert-MyDiskCHasMoreThan10PercentOfFreeSpace
    }

}