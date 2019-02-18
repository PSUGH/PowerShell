# Erstellen und verwalten einer Outlook-Regel mit PowerShell #

Ok, eine triviale Aufgabe, aber wie immer, wenn etwas einfach erscheint, stößt man auf Probleme, besonders wenn man COM-Objekte automatisieren will. Außerdem muss man darauf achten, ob man ein 64- oder ein 32-bit Outlook installiert hat. Bei 32-bit muss man darauf achten, auch die 32-bit PowerShell aufzurufen, und bei 64-bit die 64-bit PowerShell.

## Outlook per COM-Objekt ##

Outlook benutzt COM-Objekte, die auch über die PowerShell instanzieren kann. Im folgenden Skript wird geschaut, ob Outlook schon läuft, oder ob eine neue Instanz von Outlook als COM-Objekt mit ```New-Object``` instanziert werden muss.

```powershell
Add-Type -AssemblyName Microsoft.Office.Interop.Outlook
try { 
  $outlook = [Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application') 
} 
catch [Runtime.InteropServices.COMException], [Management.Automation.RuntimeException] {
  $outlook = New-Object -ComObject Outlook.Application
}
```

Anschließend werden aus der laufenden bzw. gestarteten Outlook-Session die vorhandenen Regeln ausgelesen, wenn vorhanden, und als PowerShell-Objekt ausgegeben:

```powershell

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
```
