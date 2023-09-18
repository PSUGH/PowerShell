Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http -Name 'Default'

    # Tell Pode to use Pode.Web
    Use-PodeWebTemplates -Title 'Example' -Theme Dark -EndpointName 'Default'

}