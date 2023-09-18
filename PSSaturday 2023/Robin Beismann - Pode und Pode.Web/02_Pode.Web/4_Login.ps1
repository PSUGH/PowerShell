
Start-PodeServer {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address 127.0.0.1 -Port 8080 -Protocol Http

    # Tell Pode to use Pode.Web
    Use-PodeWebTemplates -Title 'Example' -Theme Dark

    # Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # Add Authentication
    Enable-PodeSessionMiddleware -Duration 120 -Extend
    New-PodeAuthScheme -Form | Add-PodeAuthUserFile -Name 'Login'

    Set-PodeWebLoginPage -Authentication 'Login'

    #region Homepage
    Set-PodeWebHomePage -Layouts @(
        New-PodeWebHero -Title 'Welcome!' -Message 'This is the home page' -Content @(
            New-PodeWebText -Value 'Here is some text!' -InParagraph -Alignment Center
        )
    )
    #endregion
}