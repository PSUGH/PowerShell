$Trigger = New-ScheduledTaskTrigger -weekly -At 23:00 -DaysOfWeek @("Friday")

$Action = New-ScheduledTaskAction -Execute "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\sqlcmd.exe" -Argument '-I -S np:\\.\pipe\MICROSOFT##WID\tsql\query -i C:\scripts\WsusDBMaintenance.sql'

Register-ScheduledTask -TaskName WSUSDBMaintenance -TaskPath "\WSUS\" -Action $Action -Trigger $Trigger -User 'System'

