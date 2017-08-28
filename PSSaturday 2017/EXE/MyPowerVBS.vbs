Dim myObj
Set myObj = CreateObject("PowerShellExecutionLibrary.Program")
myObj.getValue("Get-Service | where {$_.Status -eq 'Stopped'} | Out-Gridview -title 'Show Services' -PassThru")
