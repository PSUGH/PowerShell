#requires -version 3.0
 
Function Test-PSRemoting {
 [cmdletbinding()]
 
  Param(
    [Parameter(Position=0,Mandatory,HelpMessage = "Enter a computername",ValueFromPipeline)]
    [ValidateNotNullorEmpty()]
    [string]$Computername,
    [Parameter(Position=1)][string]$Authentication='default',    
   [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty

  )
 
  Begin {
    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
  } #begin
 
  Process {
    Write-Verbose -Message "Testing $computername"
    Try {
      $r = Test-WSMan -ComputerName $Computername -Credential $Credential -Authentication $Authentication -ErrorAction Stop
      $True 
    }
    Catch {
      Write-Verbose $_.Exception.Message
      $False
 
    }
 
  } #Process
 
  End {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
  } #end
 
} #close function