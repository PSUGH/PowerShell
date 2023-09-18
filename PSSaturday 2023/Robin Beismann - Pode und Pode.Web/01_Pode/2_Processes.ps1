Start-PodeServer {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address * -Port 8080 -Protocol Http

    # a simple page for displaying services
    Add-PodePage -Name 'processes' -ScriptBlock { Get-Process }
}