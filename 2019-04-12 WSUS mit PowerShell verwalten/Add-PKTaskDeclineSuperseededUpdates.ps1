$Trigger = New-ScheduledTaskTrigger -weekly -At 22:00 -DaysOfWeek @("Friday")

$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument 'C:\scripts\Decline-SupersededUpdates.ps1 -UpdateServer WSUS16BS -Port 8530'

Register-ScheduledTask -TaskName DeclineSuperseededUpdates -TaskPath "\WSUS\" -Action $Action -Trigger $Trigger -User 'System'

