
Start-PodeServer {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address 127.0.0.1 -Port 8080 -Protocol Http
    
    # set the engine to use and render .pode files
    Set-PodeViewEngine -Type Pode

    # Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # render the index.pode in the /views directory
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeViewResponse -Path 'index'
    }
}