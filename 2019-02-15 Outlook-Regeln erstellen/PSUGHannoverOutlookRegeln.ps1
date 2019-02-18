#############################################################
###                                                       ###
### Outlook-Regeln erstellen und verwalten mit Powershell ###
###                                                       ###
### @datenteiler                                          ###
###                                                       ###
#############################################################


#region -- Die Aufgabe: Erstellen und verwalten einer Outlook-Regel mit PowerShell

# Ok, eine triviale Aufgabe, aber wie immer, wenn etwas einfach erscheint,  
# stößt man auf Probleme, besonders wenn man COM-Objekte automatisieren will: 

#endregion 

function New-OutlookRule {
  <#
      .SYNOPSIS
      Create a new Outlook rule.

      .DESCRIPTION
      Create or automate new Outlook rules for Microsoft Outlook.

      .PARAMETER Name
      The name of your Outlook rule.

      .PARAMETER FromEmail
      The e-mail sender.

      .PARAMETER ForwardEmail
      The e-mail recipient.

      .EXAMPLE
      New-OutlookRule -Name 'MyRule' -FromEmail 'From@Sender.com' -ForwardEmail 'To@Receiver.com'
      Create a new Outlook rule 'MyRule' with sender and recipient.

      .NOTES
      

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online New-OutlookRule

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>

  [OutputType([int])]
  param(
  
    [Parameter(Mandatory = $true,HelpMessage='Name of the Outlook rule',
        ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    [string]$Name,

    [Parameter(Mandatory = $true,HelpMessage='From eMail address')]
    [string]$FromEmail,

    # To eMail address
    [string]$ForwardEmail = '', 

    # Folder for redirection
    [string]$RedirectFolder = '',
    
    # Subject conditions
    [string[]]$WordsInSubject = $null
  )

  Add-Type -AssemblyName Microsoft.Office.Interop.Outlook
  try {
    $outlook = [Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application') 
  } 
  catch [Runtime.InteropServices.COMException], [Management.Automation.RuntimeException] {
    $outlook = New-Object -ComObject Outlook.Application
  }
  # Cast Outlook object     
  $olRuleType = 'Microsoft.Office.Interop.Outlook.OlRuleType' -as [type]
  $olFolders = "Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]

  $namespace = $Outlook.GetNameSpace("MAPI")
  $inbox = $namespace.getDefaultFolder($olFolders::olFolderInbox)

  $rules = $outlook.Session.DefaultStore.GetRules()
  $rule = $rules.Create($Name, $olRuleType::OlRuleReceive)
  
  if ($WordsInSubject -ne $null)
  {
    $SubjectCondition = $rule.Conditions.Subject
    $SubjectCondition.Enabled = $true
    $SubjectCondition.Text = $WordsInSubject    
  }
 
  $FromCondition = $rule.Conditions.From
  $FromCondition.Enabled = $true
  $null = $FromCondition.Recipients.Add($FromEmail)
  $null = $fromCondition.Recipients.ResolveAll()

  $ForwardRuleAction = $rule.Actions.Forward
  $null = $ForwardRuleAction.Recipients.Add($ForwardEmail)
  $null = $ForwardRuleAction.Recipients.ResolveAll()
  $ForwardRuleAction.Enabled = $true

    if($RedirectFolder)
    {
      try
      {
        $null = $inbox.Folders.Add($RedirectFolder)
      }
      catch
      {
        Write-Verbose "Ordner existiert bereits."
      }
    
      $MoveRuleAction = $rule.Actions.moveToFolder
      ## Doesn't work because of this bug:
      ## https://support.office.com/en-us/article/Outlook-Error-The-operation-failed-when-selecting-Manage-Rules-Alerts-64b6ff77-98c2-4564-9cbf-25bd8e17fb8b
      #$MoveRuleAction.Enabled = $true
      $MoveRuleAction.Folder = $inbox.Folders.Item($RedirectFolder)

    }
    
  # Save rule
  $null = $rules.Save()
}

function Get-OutlookRule {
  <#
      .SYNOPSIS
      Get your Outlook rules.

      .DESCRIPTION
      Shows your Outlook rules in Microsoft Outlook.

      .EXAMPLE
      Get-OutlookRule
      Shows your Outlook rules
  #>

    Add-Type -AssemblyName Microsoft.Office.Interop.Outlook
    try { 
        $outlook = [Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application') 
    } 
    catch [Runtime.InteropServices.COMException], [Management.Automation.RuntimeException] {
        $outlook = New-Object -ComObject Outlook.Application
    }
    
    $rules = $outlook.Session.DefaultStore.GetRules()

    $MyRules = @()
    for ($i = 1; $i -le $rules.Count; $i++) {
        [bool]$IsEnabled = $rules.Item($i).Enabled
        [string]$Name = $rules.Item($i).Name
        [bool]$IsLocal = $rules.Item($i).IsLocalRule
      
        $rc = New-Object -TypeName PSObject
        $rc | Add-Member -MemberType NoteProperty -Name Id -Value $i
        $rc | Add-Member -MemberType NoteProperty -Name Name -Value $Name
        $rc | Add-Member -MemberType NoteProperty -Name IsEnabled -Value $IsEnabled
        $rc | Add-Member -MemberType NoteProperty -Name IsLocal -Value $IsLocal
        $MyRules += $rc
        remove-variable -Name rc
    }
    $MyRules
}

function Remove-OutlookRule {
  <#
      .SYNOPSIS
      Remove your Outlook rule.

      .DESCRIPTION
      Removes your Outlook rule from Microsoft Outlook.

      .PARAMETER Name
      The name of the Outlook rule.

      .EXAMPLE
      Remove-OutlookRule -Name MyRule
      Remove the Outlook rule 'MyRule'. The name is case sensitive.

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Remove-OutlookRule

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>

  [OutputType([int])]
  param    (
    # Name of the Outlook rule
    [Parameter(Mandatory = $true,HelpMessage='Add help message for user',
        ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    [string]$Name
  )
  Add-Type -AssemblyName Microsoft.Office.Interop.Outlook
  try { 
    $outlook = [Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application') 
  } 
  catch [Runtime.InteropServices.COMException], [Management.Automation.RuntimeException] {
    $outlook = New-Object -ComObject Outlook.Application
  }
  $rules = $outlook.Session.DefaultStore.GetRules()
  try {
    $rules.Remove($Name)
    # Save your changes, otherwise your rule won't be removed
    $rules.Save()
  }
  catch {
    Write-Error -Message ('No rule {0} found. Please note case sensitivity.' -f $name)
  }
}