function Assert-HasFreeSpace ($Disk, $Percent) {
    $diskInfo = Get-WmiObject win32_logicaldisk |
        where DeviceId -eq ($Disk + ':')

    $diskSize = $diskInfo.Size

    $expectedFreeSpace = $diskSize * (0.01 * $Percent)
    $expectedFreeSpaceInGigabytes = [Math]::Round(
        $expectedFreeSpace / 1GB, 2)

    $freeSpace = $diskInfo.FreeSpace
    $freeSpaceInGigabytes = [Math]::Round($freeSpace / 1GB, 2)

    $freeSpaceInGigabytes |
        Should -BeGreaterThan $expectedFreeSpaceInGigabytes
}

# our check on C: for 10%
Describe 'Disk health checks' {
    It 'C: Has at least 10% of free space' {
        Assert-HasFreeSpace -Disk 'C' -Percent 10
    }
}

