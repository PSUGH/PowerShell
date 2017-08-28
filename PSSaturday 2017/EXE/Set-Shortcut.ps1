function Set-ShortCut
{
  <#
      .SYNOPSIS
      Set-ShortCut creates a shortcut with a PowerShell script

      .DESCRIPTION
      Create a shortcut with a PowerShell script included and to strat it with a double click.

      .PARAMETER TargetScript
      The PowerShell script in a scriptblock.

      .PARAMETER Description
      Description of the shortcut.

      .PARAMETER ShortcutFile
      This is the target for the shortcut file.

      .PARAMETER TargetPath
      Path to the PowerShell EXE. On 64bit systems use
      C:\Windows\SysWOW64\WindowsPowerShell\v1.0 for 32bit and
      C:\Windows\System32\WindowsPowerShell\v1.0 for 64bit PS

      .PARAMETER TargetArgs
      Parameters for powershell.exe.

      .PARAMETER WorkingDir
      Working directory of the script.

      .PARAMETER IconLocation
      Location of the icon file.

      .PARAMETER IconLocationNumber
      Number of the icon in the icon file. If more than one icon in the file 
      the numeration is vertical starting with 0:

      -------------
      | 0 | 3 | 6 |
      -------------
      | 1 | 4 | 7 |
      -------------
      | 2 | 5 |...|
      -------------

      .EXAMPLE
      Set-ShortCut -TargetScript Value -Description Value -ShortcutFile Value -TargetPath Value -TargetArgs Value -WorkingDir Value -IconLocation Value -IconLocationNumber Value
      Runs the function with the value in the parameters. If parameters are skipped the script uses the default values.

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
    # PowerShell script which will run if you double-click on the shortcut
    [Parameter(ValueFromPipeline=$true,
    Position=0)]
    [string]$TargetScript = "&{Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.MessageBox]::Show('Hello World!','Greetings',0,'Info')}",
        
    # Path to the executable for the link
    [string]$TargetPath = "$PSHOME\powershell.exe",
        
    # Parameters here are -WindowStyle Hidden, -NoExit, -NoProfile and -Command
    [string]$TargetArgs = '-w h -noex -nop -c',
    
    [string]$Description = 'My first link with PowerShell script',
        
    # Name of the created shortcut.
    [string]$ShortcutFile = "C:\Users\Christian\Desktop\HelloWorld.lnk",
        
    [string]$WorkingDir = $PSHOME,
        
    # File with stored icons. Shell32.dll is a standard file for that.
    [string]$IconLocation = "$env:windir\System32\SHELL32.dll",
        
    # The number of the icon in the icon file.
    [int]$IconLocationNumber = 0
    )

    Begin
    {
      $WScriptShell = New-Object -ComObject WScript.Shell
      $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    }
    Process
    {
      # Get target length
      [int]$TargetLength=$TargetScript.Length+$TargetPath.Length+$TargetArgs.length
      if ($TargetLength -gt 255)
      {
        Write-Output -InputObject "`nThis won't work: Windows shortcuts have a 255 character limit on their target property."
        break
      }
      
      $Shortcut.TargetPath       = $TargetPath
      $Shortcut.Arguments        = ('{0} {1}' -f $TargetArgs, $TargetScript)
      $Shortcut.WorkingDirectory = $WorkingDir
      $Shortcut.Description      = ('{0}' -f $Description)
      $Shortcut.IconLocation     = ('{0}, {1}' -f $IconLocation, $IconLocationNumber)      
    }
    End
    {
      $Shortcut.Save()
    }
}
