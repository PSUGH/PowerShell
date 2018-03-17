 <#
    .SYNOPSIS 
    Shows entry from /etc/passwd 

    .DESCRIPTION
    Get-User shows all the user in /etc/passwd 

   .EXAMPLE
    PS /> Import-Module ./Get-User.psm1

   .EXAMPLE
    PS /> Get-User   

   .EXAMPLE
    PS /> Get-User -Username <username>

    .EXAMPLE
    PS /> Get-User | Where-Object {$_.Name -match "root"}
    
    .EXAMPLE
    PS /> Get-User | ft
#>

function Get-User ($Username = $null) 
{
    $csvlist = cat /etc/passwd | ConvertFrom-CSV -Delimiter ':' -Header Name,Passwd,UID,GID,Description,Home,Shell
    if ($Username -ne $null) {
        $csvlist | Where-Object {$_.Name -eq $Username}
    }
    else {
        $csvlist | Sort-Object Name
    }
}
