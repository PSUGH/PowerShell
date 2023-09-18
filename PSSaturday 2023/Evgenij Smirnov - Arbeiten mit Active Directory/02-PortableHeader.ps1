#region ganz falsch
$Domain = 'ad.firma.de'
$Credential = Import-Clixml -Path "$PSScriptRoot\cred.xml"
#endregion
#region guter Ansatz, aber nicht optimal
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [string]$Domain = 'ad.firma.de',
    [Parameter(Mandatory=$true)]
    [PSCredential]$Credential
)
#endregion
#region schon viel, viel besser!
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [string]$Domain,
    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential
)
if ([string]::IsNullOrWhiteSpace($Domain)) {
    $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
}
$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
$ldapArgs = @('LDAP://{0}/rootDSE' -f $Domain)
if ($null -ne $Credential) {
    $ldapArgs += $Credential.UserName
    $ldapArgs += $Credential.GetNetworkCredential().Password
}
$rootDSE = New-Object System.DirectoryServices.DirectoryEntry($ldapArgs)
# NB: Objekt ist erzeugt, wird aber erst beim Zugriff initialisiert!
try {
    $rootDSE.RefreshCache()
    $rootDSE | fl *
} catch {
    Write-Warning $_.Exception.Message
}
#endregion