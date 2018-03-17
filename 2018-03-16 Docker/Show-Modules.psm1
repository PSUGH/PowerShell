 <#
    .SYNOPSIS 
    Show the status of modules 

    .DESCRIPTION
    Show-Modules shows the status of modules in the Linux Kernel

   .EXAMPLE
    PS /> Show-Modules

    .EXAMPLE
    PS /> Show-Modules | Where-Object {$_.Module -match "video"}
#>

function Show-Modules {
    lsmod | Select-Object -skip 1 |
    foreach {
        ($_.tostring() -replace ' {2,}',"`t")
    } |
    ConvertFrom-CSV -Delimiter "`t" -Header Module,Size,UsedBy |
    Sort-Object Module 
}
