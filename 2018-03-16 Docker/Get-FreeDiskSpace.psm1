 <#
    .SYNOPSIS 
    Shows free disk space

    .DESCRIPTION
    Get-FreeDiskSpace shows the free disk space 

   .EXAMPLE
    PS /> Import-Module ./Get-FreeDiskSpace.psm1

   .EXAMPLE
    PS /> Get-FreeDiskSpace

   .EXAMPLE
    PS /> Get-FreeDiskSpac | Format-Table
#>

function Get-FreeDiskSpace {

    $csvlist = df -h | sed 's/ \+/,/g'
    $csvlist |  Select-Object -skip 1 |
    ConvertFrom-CSV -Delimiter "," -Header Filesystem,Size,Used,Avail,Use%,'Mounted on'
}
