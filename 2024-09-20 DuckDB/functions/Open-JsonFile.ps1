function Open-JsonFile {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )

    try {
        # Check if the input is a string
        if ($InputObject -is [System.String]) {
            $filePath = $InputObject
            Write-PSFMessage -Level Verbose -Message "Input object is a string (file path)" -FunctionName $MyInvocation.MyCommand.Name
        }
        # Check if the input has a FullName property (like a FileInfo object)
        elseif ($InputObject.PSObject.Properties.Name -contains 'FullName') {
            $filePath = $InputObject.FullName
            Write-PSFMessage -Level Verbose -Message "Input object has a FullName property" -FunctionName $MyInvocation.MyCommand.Name
        } else {
            throw "Invalid input type. Expected a file path (string) or an object with a FullName property."
        }

        Write-PSFMessage -Level Verbose -Message "Attempting to open file: $filePath" -FunctionName $MyInvocation.MyCommand.Name

        # Verify the file exists
        if (-not (Test-Path $filePath)) {
            throw "File not found: $filePath"
        }

        # Attempt to read and parse the JSON file
        $jsonContent = Get-Content $filePath -Raw | ConvertFrom-Json
        Write-PSFMessage -Level Verbose -Message "Successfully opened and parsed JSON file: $filePath" -FunctionName $MyInvocation.MyCommand.Name
        return $jsonContent
    } catch {
        Write-PSFMessage -Level Error -Message "Error processing JSON file: $_" -ErrorRecord $_ -FunctionName $MyInvocation.MyCommand.Name
        return $null
    }
}