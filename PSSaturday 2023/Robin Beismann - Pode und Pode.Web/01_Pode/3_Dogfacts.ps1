Start-PodeServer {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address 127.0.0.1 -Port 8080 -Protocol Http

    # Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # a simple page for displaying facts from an external API
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        $result = Invoke-RestMethod -Uri 'https://dogapi.dog/api/v2/facts?limit=5'
        
        Write-PodeHtmlResponse -Value ($result.data.attributes.body -join "<br/>") 
    }
}