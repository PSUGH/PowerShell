<#
Name: Fred
Twitter: @FredWeinmann
Project:

- https://psframework.org
- https://admf.one
#>

# PSFramework
Install-Module PSFramework

# Configuration
Get-PSFConfig -Module PSUtil
Set-PSFConfig -FullName PSUtil.Path.BackupStepsDefault -Value "nachher"
Set-PSFConfig -FullName PSUtil.Path.BackupStepsDefault -Value 2
Set-PSFConfig -FullName PSUtil.Path.BackupStepsDefault -Value 2 -PassThru | Register-PSFConfig

Get-Item F:\temp\dba.json

code F:\temp\dba.json

Get-PSFConfig -Module dbachecks

Import-PSFConfig -Path F:\temp\dba.json
Get-PSFConfigValue -FullName PSUtil.Path.Temp

# https://psframework.org

# Logging
<#
- Umgebungsspezifisch
- Parallelisieren == Lock / Konflikt
- Metainformation
#>

Write-Log "Nachricht"
Write-PSFMessage "Nachricht"

function Get-Test {
    [CmdletBinding()]
    param ()

    Write-Verbose "Hallo Welt"
    Write-PSFMessage "Hallo neue Welt"
}

Get-Test
Get-Test -Verbose
Get-PSFMessage
$msg = Get-PSFMessage | select -Last 1
$msg | fl *
Get-PSFRunspace
II (Get-PSFConfigValue PSFramework.Logging.FileSystem.LogPath)
Import-Csv -Path 'C:\Users\Friedrich\AppData\Roaming\PowerShell\PSFramework\Logs\HEL_47124_message_0.log'

Get-PSFLoggingProvider
Set-PSFLoggingProvider -Name logfile -InstanceName MyDemo -FilePath C:\temp\mylog.csv -Enabled $true
Write-PSFMessage -Level Error -Message "Die Welt Brennt (und mein Bier ist leer)" -Tag beer, catastrophe -Target Bierkrug
code C:\temp\mylog.csv

$paramSetPSFLoggingProvider = @{
    Name          = 'logfile'
    InstanceName  = 'MyDemo2'
    FilePath      = 'C:\temp\mylog-%date%.json'
    IncludeTags   = 'error'
    FileType      = 'Json'
    UTC           = $true
    Headers       = 'Timestamp', 'Message', 'Tags', 'Target', 'Data'
    LogRotatePath = 'C:\temp\mylog-*.json'
    JsonCompress  = $true
    JsonNoComma   = $true
    Enabled       = $true
}

Set-PSFLoggingProvider @paramSetPSFLoggingProvider
Write-PSFMessage -Level Warning -Message "Bier immer noch leer" -Tag error
Write-PSFMessage -Level Warning -Message "Bier immer noch leer" -Tag error -Data @{
    Brand = "Hofbräu"
    Level = "Kritisch"
}

Write-PSFMessage -Level Host -Message "Bier wieder voll"
dir C:\temp\
code C:\temp\mylog-2021-02-19.json

Get-PSFConfig *logfile*
$instance = (Get-PSFLoggingProviderInstance)[0]
$instance | fl
$instance.BeginCommand
$instance.BeginCommand.Definition
$instance.MessageCommand
$instance.MessageCommand.Definition

& $instance.MessageCommand $null


# PSFScriptBlock
$code = { Write-Host "Hallo $_" }
& $code "Peter"
$code = { Write-Host "Hallo $($args[0])" }
& $code "Peter"
$scb = [PsfScriptBlock] { Write-Host "Hallo $_" }
$scb.InvokeEx("Peter", $true, $false, $false)

$scb = [PsfScriptBlock] {
    $zufall = 1..10 | Get-Random
    Write-Host "Zahl: $zufall"
}

$scb.InvokeEx($true, $false, $false)
$zufall
$scb.InvokeEx($false, $false, $false)
$zufall
$scb.InvokeEx

New-Module -Name Test -ScriptBlock {
    $script:zahl = 42
    function Invoke-Code {
        [CmdletBinding()]
        param (
            [PSFramework.Utility.PsfScriptBlock]
            $Code,
            [switch]
            $Import,
            [switch]
            $DoGlobal
        )
        $Code.InvokeEx($true, $Import, $DoGlobal)
    }

}

Invoke-Code -Code { $ExecutionContext.SessionState } -Import -DoGlobal


# Tab Completion

function Get-Test {
    [CmdletBinding()]
    param (
        [ValidateSet('File', 'Directory')]
        $Type
    )
}
Get-Test -Type File

function Get-Alcohol {
    [CmdletBinding()]
    Param (
        [string]
        $Type,
        [string]
        $Unit = "Pitcher"
    )

    Write-Host "Drinking a $Unit of $Type"
}
Get-Alcohol -Type Beer

Register-PSFTeppScriptblock -Name "alcohol" -ScriptBlock { 'Beer', 'Mead', 'Whiskey', 'Wine', 'Vodka', 'Rum (3y)', 'Rum (5y)', 'Rum (7y)' }
Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Type -Name alcohol
Get-Alcohol -Type Vodka
Get-Alcohol -Type Mojito

function Get-Alcohol {
    [CmdletBinding()]
    Param (
        [PsfValidateSet(TabCompletion = 'alcohol')]
        [string]
        $Type,
        [string]
        $Unit = "Pitcher"
    )
    Write-Host "Drinking a $Unit of $Type"
}

Get-Alcohol -Type Mojito


# Caching

Register-PSFTeppScriptblock -Name "alcohol" -ScriptBlock { 'Beer', 'Mead', 'Whiskey', 'Wine', 'Vodka', 'Rum (3y)', 'Rum (5y)', 'Rum (7y)' } -CacheDuration 8h

function Get-Alcohol2 {
    [CmdletBinding()]
    Param (
        [PsfArgumentCompleter("alcohol")]
        [PsfValidateSet(TabCompletion = 'alcohol')]
        [string]
        $Type,
        [string]
        $Unit = "Pitcher"
    )
    
    Write-Host "Drinking a $Unit of $Type"
}

Get-Alcohol2 -Type Whiskey

Register-PSFTeppScriptblock -Name Alcohol.MugSize -ScriptBlock {
    switch ($fakeBoundParameter.Type) {
        'Mead' { 'Mug', 'Horn', 'Barrel' }
        'Wine' { 'Glas', 'Bottle' }
        'Beer' { 'Halbes Maß', 'Maß' }
        default { 'Glas', 'Pitcher' }
    }
}

Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Unit -Name Alcohol.MugSize
Get-Alcohol -Type Beer -Unit Maß
Get-Alcohol -Type Mead -Unit Horn


# License
Get-PSFLicense

# Callbacks
New-Module -Name ModuleA -ScriptBlock {
    function Get-TestA {
        [CmdletBinding()]
        param ()
        Invoke-PSFCallback -Data @{ Zahl = 42 }
        Write-Host "Executing A"
    }
}

Get-TestA

Register-PSFCallback -ModuleName ModuleA -CommandName Get-TestA -Name MyCallback -ScriptBlock {
    param (
        $Data
    )
    Write-Host "Running Callback"
    $Data.Data.Zahl | Out-Host
}


# Select-PSFObject
dir C:\windows -File | Select-Object Name, Length
dir C:\windows -File | Select-Object Name, @{ Name = "Size"; Expression = { $_.Length } }
dir C:\windows -File | Select-Object Name, @{ Name = "Size"; Expression = { '{0:N2} MB' -f ($_.Length / 1MB) } }
dir C:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize'
$res = dir C:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize' | Sort Size
$res[-1].Size
dir C:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize', 'LastWriteTime.Year as Year'
dir C:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize', 'LastWriteTime.Year as Year', 'LastWriteTime.ToString("yyyy-MM-dd") as Date'
$file1 = dir C:\windows -File
$file2 = dir C:\windows -File
$file1 | Select-PSFObject Name, LastWriteTime, "Length from file2 where Name = Name"


# ConvertFrom-PSFArray
$object = [PSCustomObject]@{
    Name = "Peter"
    Zahl = 23, 42
}

$object
