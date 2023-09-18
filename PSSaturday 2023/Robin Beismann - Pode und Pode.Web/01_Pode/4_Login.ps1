
Start-PodeServer {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address 127.0.0.1 -Port 8080 -Protocol Http

    # Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # Add Authentication
    New-PodeAuthScheme -Basic | Add-PodeAuthUserFile -Name 'Login' -Sessionless

    Add-PodeRoute -Method Get -Path '/' -Authentication 'Login' -ScriptBlock {
        Write-PodeTextResponse -Value "Hello $($WebEvent.Auth.User.Username)! Your mail address is $($WebEvent.Auth.User.Email)."
    }    
}