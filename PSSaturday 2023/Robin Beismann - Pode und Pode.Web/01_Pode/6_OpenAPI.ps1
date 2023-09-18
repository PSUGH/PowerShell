
Start-PodeServer {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address 127.0.0.1 -Port 8080 -Protocol Http

    # Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    #region API Definition Endpoint
    # http://localhost:8080/docs/openapi
    Enable-PodeOpenApi -Path '/docs/openapi' -Title 'My Awesome API' -Version 9.0.0.1
    #endregion

    #region Swagger
    # http://localhost:8080/docs/swagger
    Enable-PodeOpenApiViewer -Type Swagger -Path '/docs/swagger' -DarkMode
    #endregion

    #region Simple response
    # http://localhost:8080/api/resources
    Add-PodeRoute -Method Get -Path "/api/resources" -ScriptBlock {
        Write-PodeJsonResponse -Value @{
            "Foo" = "bar"
        }
        Set-PodeResponseStatus -Code 200
    } -PassThru |
        Set-PodeOARouteInfo -Summary 'Retrieve some resources' -Tags 'Resources'
    #endregion

    #region User Validation
    Add-PodeRoute -Method Get -Path "/api/user/:userId" -ScriptBlock {
        if($WebEvent.Parameters['userId'] -eq "pssat"){
            Write-PodeTextResponse -Value "PSSat found!"
            Set-PodeResponseStatus -Code 200
        }else{
            Set-PodeResponseStatus -Code 404
        }
    } -PassThru |
        Add-PodeOAResponse -StatusCode 200 -PassThru |
        Add-PodeOAResponse -StatusCode 404 -Description 'User not found'
    #endregion
}