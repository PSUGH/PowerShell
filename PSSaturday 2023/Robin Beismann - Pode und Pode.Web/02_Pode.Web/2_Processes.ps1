Import-Module -Name Pode.Web

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http -Name 'Default'

    # Tell Pode to use Pode.Web
    Use-PodeWebTemplates -Title 'Example' -Theme Dark -EndpointName 'Default'

    Add-PodeWebPage -Name 'Processes' -Icon 'Settings' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Processes' -ScriptBlock {
                Get-Process | Sort-Object -Property 'PM' -Descending | ForEach-Object {
                    [ordered]@{
                        Name   = $_.ProcessName
                        PID = $_.Id
                        Memory = "$( [math]::Round(($_.PM / 1024 / 1024),2) )MB"
                    }
                }
            } `
            -Compact
            # -AutoRefresh -RefreshInterval 5
        )
    }
}