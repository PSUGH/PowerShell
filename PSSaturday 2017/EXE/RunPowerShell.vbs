Dim myObj
Set myObj = WScript.CreateObject("WScript.Shell")
With CreateObject("WScript.Shell")
	.run "powershell -noexit -command ""&{0..15 | % {Write-Host -foreground $_ 'Hello World' }}""", 1, True '' 0 hide cmd, 1 show cmd
End With
