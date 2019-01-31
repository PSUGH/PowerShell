#Karsten Schulze - frinx.it GmbH
#Anpassungen für PSUGH 18. Januar 2019

#Voraussetzungen für dieses Beispiel:
#Ein 'gesyspreptes' Windows 10 (oder die mit Holgers Modul erstellte) als w10.vhdx
#Eine Template für die unattend.xml mit dem Namen w10.xml
#Einen Ordner C:\temp (hier liegt dieses Script) mit Unterordnern
#                 \IMAGES (hier hinein die VHDX und das XML-Template)
#                 \Vhd    (hier wird die neue VHDX für die VM angelegt)

function New-Vpc {
    <#
            .SYNOPSIS
            New-Vpc [-VpcName] <string>  
            [ [-Hostname '.'] [-VpcGeneration <int16>] [-VpcDynamicMemory <bool>] 
            [-VpcStartupMemory <int64>] [-VpcMaxMemory <int64>] [-VpcProcessorCount <int16>] 
            [-VpcDiskSize <int64>] [-MachineType <string>] 
            [-VpcTemplateName <string>] [-DiskTemplatePath <string>] [-VhdPath <string>] [-NewVhdx <string>] 
            [-UnattendFile <string>]
            [-Domain <string>] [-DomainUser <string>] [-DomainUserPw <string>] [-LocalAdminPw <string>]
            [-SwitchName <string>] 
            [-IndependendDisk <switch>] [-StartVm <switch>] ]

            .DESCRIPTION
            Anlage eines neuen Windows 10 64Bit VPCs
            - Bereitstellung auf Basis eines vorbereiteten Templates
            - Independend oder Differencing Disk
            - Defaults: Differencing Disk
                VpcTemplateName w10.vhdx
                DiskTemplatePath C:\Temp\IMAGES (folder for sysprepped template and unattend.xml)
                VhdPath C:\Temp\Vhd (folder to store virtual harddisk files)
                UnattendFile C:\Temp\IMAGES\w10.xml
                ProcessorCount 2
                Generation 2
                VpcStartupMemory 2048
                VpcMaxMemory 4096 dynamic
                SwitchName VDI-INTERN
                HostName .
        Benamung des VPC: Präfix VPC + 5 numerische Stellen,
        aus den letzten numerischen Stellen wird die MACID berechnet!

            .EXAMPLE
            New-Vpc [-VpcName] 'VPC00123' [-SwitchName VDI-EXTERN | VDI-INTERN]
            New-Vpc VPC00123
            - Erstellt einen neuen VPC auf Basis des Images w10.vhdx
            auf differencing Disk, 2 Prozessoren, 2GB Startram, 4GB Maxram, Disk Dynamisch mit max 60GB
            [-SwitchName VDI-EXTERN: in der Integrationsumgebung]

            New-Vpc [-VpcName] 'VPC00123' -VpcTemplateName '(vhdname).vhdx' 
            - Erstellt einen neuen VPC auf Basis des Images (vhdname).vhdx  auf differencing Disk. 

            New-Vpc [-VpcName] 'VPC00123' -VpcTemplateName 'w10.vhdx' -VpcProcessorCount 4 -IndependendDisk -Startvm
            - Erstellt einen neuen VPC auf Basis des Images w10.vhdx auf eigenständiger Disk 
            mit 4 Prozessoren und startet den VPC anschließend
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $VpcName,
        
        [Parameter(Position = 1)]
        [System.String]
        $HostName = '.',
        
        [Parameter(Position = 2)]
        [System.Int32]
        $VpcGeneration = 2,
        
        [Parameter(Position = 3)]
        [bool]
        $VpcDynamicMemory = $true,
        
        [Parameter(Position = 4)]
        [System.Int64]
        $VpcStartupMemory = 2147483648,
        
        [Parameter(Position = 5)]
        [System.Int64]
        $VpcMaxMemory = 4294967296,
        
        [Parameter(Position = 6)]
        [System.Int32]
        $VpcProcessorCount = 2,
        
        [Parameter(Position = 7)]
        [System.Int64]
        $VpcDiskSize = 64424509440,
        
        [Parameter(Position = 8)]
        [System.String]
        $SwitchName = 'VDI-INTERN',
        
        [Parameter(Position = 9)]
        [System.String]
        $VpcTemplateName = 'w10.vhdx',
        
        [Parameter(Position = 10)]
        [System.String]
        $DiskTemplatePath = 'C:\Temp\IMAGES\',
        
        [Parameter(Position = 11)]
        [System.String]
        $VhdPath = 'C:\Temp\Vhd\',
        
        [Parameter(Position = 12)]
        [System.String]
        $UnattendFile = 'w10.xml',
                
        [Parameter(Position = 13)]
        [System.String]
        $NewVhdx = ('{0}.vhdx' -f $VpcName),
        
        [Parameter(Position = 14)]
        [System.String]
        $Domain = 'test.localdomain',
        
        [Parameter(Position = 15)]
        [System.String]
        $DomainUser = 'DomainUserName',
        
        [Parameter(Position = 16)]
        [System.String]
        $DomainUserPw = 'DomainUserPassword',
        
        [Parameter(Position = 17)]
        [System.String]
        $LocalAdminPW = 'LocalAdminPassword',
        
        [Parameter(Position = 18)]
        [Switch]
        $IndependendDisk,

        [Parameter(Position = 19)]
        [Switch]
        $StartVm
    )
    
    
    if (Get-VM -Name $VpcName -ErrorAction SilentlyContinue) {
        Write-Verbose -Message 'VPC existiert bereits'
        break
    } 
    else {
        Write-Verbose -Message 'VPC wird jetzt erstellt'
    }
    
    Set-Location -Path $DiskTemplatePath

    # MacID berechnen
    $VpcNetworkAdapterMacSuffix = '{0:x6}' -f [int]$VpcName.SubString(3)
    $VpcNetworkAdapterMac = ('00155D{0}' -f $VpcNetworkAdapterMacSuffix)

    # HD full oder differencial
    if ($IndependendDisk.IsPresent) {
        # Create IndependendDisk Clone
        # Macht Probleme: Copy-Item -Path "$DiskTemplatePath$VpcTemplateName" -Destination "$VhdPath$NewVhdx"
        # deshalb Robocopy:
        & "$env:windir\system32\robocopy.exe" /r:3 /w:3 /np $DiskTemplatePath $VhdPath\ $VpcTemplateName

        <# Bei Verwendung von Copy-Item
                Get-Item -Path "$VhdPath$NewVhdx" | ForEach-Object -Process {
                $_.Attributes = 'Normal'
        #>

        # Nur bei Robocopy
        Get-Item -Path ('{0}{1}' -f $VhdPath, $VpcTemplateName) | ForEach-Object -Process {
            $_.Attributes = 'Normal'
            Rename-Item -Path ('{0}{1}' -f $VhdPath, $VpcTemplateName) -NewName ('{0}{1}' -f $VhdPath, $NewVhdx)
            # Nur bei Robocopy END
        }
    }
    else {
        #Create differencing Disk
        New-VHD -ParentPath ('{0}{1}' -f $DiskTemplatePath, $VpcTemplateName) -Path ('{0}{1}' -f $VhdPath, $NewVhdx) -SizeBytes $VpcDiskSize
    }
    # Wait for disk mount
    Start-Sleep -Seconds 2

    $Scriptpath = Get-Location

    #
    $Disk = Mount-VHD -Path ('{0}{1}' -f $VhdPath, $NewVhdx) -Passthru | Get-Disk
    $Drive = $Disk |
        Get-Partition | 
        Where-Object { $_.Size -gt 10000000000 } | 
        Select-Object -ExpandProperty Driveletter
    $Drive = ('{0}:' -f $Drive)
    $UnattendTargetPath = ('{0}\Windows\Panther\unattend.xml' -f $Drive)
    $UnattendFile = ('{0}{1}' -f $DiskTemplatePath, $UnattendFile)

    
    # Edit UnattendFile
    $UnattendfileContent = Get-Content -Path $UnattendFile
    $UnattendfileContent = $UnattendfileContent.replace('[DOMAIN]', $Domain)
    $UnattendfileContent = $UnattendfileContent.replace('[INSTUSRNTPWD]', $DomainUserPw)
    $UnattendfileContent = $UnattendfileContent.replace('[INSTUSRNT]', $DomainUser)
    $UnattendfileContent = $UnattendfileContent.replace('[PCNAME]', $VpcName)
    $UnattendfileContent = $UnattendfileContent.replace('[ADMINPW]', $LocalAdminPW)
    Set-Content -Path $UnattendTargetPath -Value $UnattendfileContent

    Set-Location -Path $Scriptpath
    
    # Test: Kontrolle der editierten unattend.xml
    Set-Content -Path $Scriptpath\$VpcName.xml -Value $UnattendfileContent

    Dismount-VHD -Path ('{0}{1}' -f $VhdPath, $NewVhdx)

    # Create VM
    New-VM -Name $VpcName -MemoryStartupBytes $VpcStartupMemory -Generation $VpcGeneration -VHDPath ('{0}{1}' -f $VhdPath, $NewVhdx) -BootDevice VHD -ComputerName . -SwitchName $SwitchName
    Set-VMNetworkAdapter -VMName $VpcName -StaticMacAddress $VpcNetworkAdapterMac
    Set-VMProcessor -VMName $VpcName -ComputerName $HostName -Count $VpcProcessorCount
    Set-VMMemory -VMName $VpcName -ComputerName $HostName -DynamicMemoryEnabled $VpcDynamicMemory -MaximumBytes $VpcMaxMemory -MinimumBytes $VpcStartupMemory -StartupBytes $VpcStartupMemory

    if ($StartVm.IsPresent) {
        Start-VM -Name $VpcName
        Write-Verbose -Message ('{0} wurde gestartet' -f $Vpcname)
    }

    # Vars:
    ('Hyper-V Host: {0}' -f $HostName) 
    ('VPC: {0}' -f $VpcName)
    ('Hyper-V Generation: {0}' -f $VpcGeneration)
    ('MacID: {0}' -f $VpcNetworkAdapterMac)
    ('Dynamic Memory: {0}' -f $VpcDynamicMemory)
    ('Startup Memory: {0}' -f $VpcStartupMemory)
    ('Max Memory: {0}' -f $VpcMaxMemory)
    ('Processors: {0}' -f $VpcProcessorCount)
    ('Disksize: {0}' -f $VpcDiskSize)
    ('Disktemplate: {0}' -f $VpcTemplateName)
    ('Disktemplatepath: {0}' -f $DiskTemplatePath)
    ('Vhdxpath: {0}' -f $VhdPath)
    ('Vhdxname: {0}' -f $NewVhdx)
    ('Unattendfile: {0}' -f $Unattendfile)
    ('Domain to join: {0}' -f $Domain)
    ('Domainuser: {0}' -f $DomainUser)
    ('DomainuserPW: {0}' -f $DomainUserPw)
    ('LocaladminPW: {0}' -f $LocalAdminPW)

}
function Remove-Vpc {
    <#
            .SYNOPSIS
            Löscht VPC und zugehörige Festplatte ohne Rückfrage!
            .DESCRIPTION
            Detailed Description
            .EXAMPLE
            Remove-Vpc [-VpcName] VPCnnnnn [-HostName] MEINSERVER
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $VpcName,
        
        [Parameter(Position = 1)]
        [System.String]
        $HostName = '.'
    )
    
    $Vmguid = Get-VM -Name $VpcName -ComputerName $HostName | Select-Object -ExpandProperty VMId
    $VhdPath = Get-vhd -VMId $Vmguid -ComputerName $HostName | Select-Object -ExpandProperty Path
    Stop-VM -Name $VpcName -Computername $HostName -TurnOff
    Remove-VM -Name $VpcName -ComputerName $HostName -force
    Remove-Item -Path $VhdPath -Force
}

function Install-Vpc {
    <#
            .SYNOPSIS
            Shortcut zur Installation eines VPC mit Windows 10 64Bit
            
            .DESCRIPTION
            Detailed Description
            .EXAMPLE
            Install-Vpcw10 [-VpcName] VPCnnnnn [[-HostName] MEINPC]
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $VpcName,
        
        [Parameter(Position = 1)]
        [System.String]
        $HostName = '.'
    )
    New-Vpc -VpcName $VpcName -VpcGeneration 2 -VpcTemplateName w10.vhdx -UnattendFile w10.xml -SwitchName VDI-INTERN -Start    
}
