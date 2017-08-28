#requires -Version 2.0
function Enable-CredSSPClient 
{
    <#
            .SYNOPSIS
            Enables and configures CredSSP Authentication to be used in PowerShell remoting sessions

            .DESCRIPTION
            Enabling CredSSP allows a caller from one remote session to authenticate on other remote 
            resources. This is known as credential delegation. By default, PowerShell sessions do not 
            use credSSP and therefore cannot bake a "second hop" to use other remote resources that 
            require their authentication token.

            Enable-CredSSPClient allows remote host to use credential delegation 
            in the case where one might keep some resources on another remote machine that need to be 
            installed into their current remote session.

            This command will enable CredSSP and add all RemoteHostsToTrust to the CredSSP trusted 
            hosts list. It will also edit the users group policy to allow Fresh Credential Delegation.

            .PARAMETER RemoteHostsToTrust
            A list of ComputerNames to add to the CredSSP Trusted hosts list.

            .OUTPUTS
            A list of the original trusted hosts on the local machine.

            .EXAMPLE
            Enable-CredSSP srv1, srv2



    #>
    [CmdletBinding()]
    param( 
        [Parameter(Position = 0)]
        [alias('Servername')][string[]]$RemoteHostsToTrust
    )
    
    $Result = @{
        Success                              = $False
        PreviousCSSPTrustedHosts             = $null
        PreviousFreshCredDelegationHostCount = 0
    }

    Write-Verbose -Message 'Configuring CredSSP settings...'
    $credssp = Get-WSManCredSSP

    $ComputersToAdd = @()
    $idxHosts = $credssp[0].IndexOf(': ')
    if($idxHosts -gt -1)
    {
        $credsspEnabled = $True
        $Result.PreviousCSSPTrustedHosts = $credssp[0].substring($idxHosts+2)
        $hostArray = $Result.PreviousCSSPTrustedHosts.Split(',')
        $RemoteHostsToTrust |
        Where-Object -FilterScript {
            $hostArray -notcontains "wsman/$_"
        } |
        ForEach-Object -Process {
            $ComputersToAdd += $_
        }
    }
    else 
    {
        $ComputersToAdd = $RemoteHostsToTrust
    }

    if($ComputersToAdd.Count -gt 0)
    {
        Write-Verbose -Message "Adding $($ComputersToAdd -join ',') to allowed credSSP hosts" -Verbose
        try 
        {
            $null = Enable-WSManCredSSP -DelegateComputer $ComputersToAdd -Role Client -Force -ErrorAction Stop
        } 
        catch 
        {
            Write-Error -Message "Enable-WSManCredSSP failed with: $_" -Verbose
            return $Result
        }
    }

    $key = Get-CredentialDelegationKey
    if (!(Test-Path -Path "$key\CredentialsDelegation")) 
    {
        $null = New-Item -Path $key -Name CredentialsDelegation
    }
    $key = Join-Path -Path $key -ChildPath 'CredentialsDelegation'
    $null = New-ItemProperty -Path "$key" -Name 'ConcatenateDefaults_AllowFresh' -Value 1 -PropertyType Dword -Force
    $null = New-ItemProperty -Path "$key" -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -Value 1 -PropertyType Dword -Force

    $Result.PreviousFreshNTLMCredDelegationHostCount = Set-CredentialDelegation -key $key -subKey 'AllowFreshCredentialsWhenNTLMOnly' -allowed $RemoteHostsToTrust
    $Result.PreviousFreshCredDelegationHostCount = Set-CredentialDelegation -key $key -subKey 'AllowFreshCredentials' -allowed $RemoteHostsToTrust

    $Result.Success = $True
    return $Result
}

function Set-CredentialDelegation
{
    param
    (
        $key,

        $subKey,

        $allowed
    )
    $null = New-ItemProperty -Path "$key" -Name $subKey -Value 1 -PropertyType Dword -Force
    $policyNode = Join-Path -Path $key -ChildPath $subKey
    if (!(Test-Path -Path $policyNode)) 
    {
        $null = mkdir -Path $policyNode
    }
    $currentHostProps = @()
    (Get-Item -Path $policyNode).Property | ForEach-Object -Process {
        $currentHostProps += (Get-ItemProperty -Path $policyNode -Name $_).($_)
    }
    $currentLength = $currentHostProps.Length
    $idx = $currentLength
    $allowed |
    Where-Object -FilterScript {
        $currentHostProps -notcontains "wsman/$_"
    } |
    ForEach-Object -Process {
        ++$idx
        $null = New-ItemProperty -Path $policyNode -Name "$idx" -Value "wsman/$_" -PropertyType String -Force
    }

    return $currentLength
}

function Get-CredentialDelegationKey 
{
    return 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'
}
