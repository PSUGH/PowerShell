# Don't run everything, thanks @alexandair!
break

# Set some vars
$ins1 = 'Server1'
$ins2 = 'Server2'
$allservers = $ins1, $ins2

$samples = 'D:\samples\'
$share = '\\Server1\share'

# Reset-SqlAdmin
Reset-DbaAdmin -SqlInstance $ins2 -Login sa -Force

# DbaStartupParameter
Get-DbaStartupParameter -SqlInstance $ins1

# script out objects
$options = New-DbaScriptingOption
$options.ScriptDrops = $false
$options.WithDependencies = $true
Get-DbaAgentJob -SqlInstance $ins1 | Export-DbaScript -ScriptingOptionObject $options -Path $samples

# Internal config 
Get-DbaConfig
