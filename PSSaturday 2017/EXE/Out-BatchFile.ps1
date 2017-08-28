#requires -version 3.0
function Out-BatchFile
{
  <#
      .SYNOPSIS
      Out-BatchFile turns a PowerShell script into a batch file.

      .DESCRIPTION
      Out-BatchFile turns a PowerShell script base64 encoded into a batch file
      to run the script with a double click.

      .PARAMETER ScriptFile
      Path to the PowerShell script.

      .PARAMETER BatchFile
      Path to the batch file.

      .EXAMPLE
      Out-BatchFile -ScriptFile Value -BatchFile Value
      Turns a PowerShell script into a batch file.

      .NOTES
      Christian Imhorst 
      @datenteiler 
      http://www.datenteiler.de 
      
      .LINK
      http://github.com/datenteiler 

  #>

    [OutputType([int])]
    Param
    (
        # ScriptFile help description
        [Parameter(Mandatory=$true,HelpMessage='Path to the PowerShell script file.',
                   ValueFromPipeline=$true,
                   Position=0)]
        [string]$ScriptFile,

        # BatchFile help description
        [Parameter(Mandatory=$true,HelpMessage='Path to the batch file.',
                   Position=1)]
        [string]$BatchFile
    )
    
    Process   
    {
      $code = $(Get-Content -Path $ScriptFile -Raw)
      $code = "Clear-Host`n" + $code

      # Encode the PowerShell script to Base64
      $coding = [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))
      $batch = ("ECHO OFF`nCLS`nPOWERSHELL.EXE -NoProfile -ExecutionPolicy Bypass -EncodedCommand {0}`nECHO.`nEXIT /B" -f $coding)
      
      # PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -EncodedCommand {0}' -Verb RunAs}" 
    
      Set-Content -Path $BatchFile -Value $batch -Encoding Ascii
    }
}
