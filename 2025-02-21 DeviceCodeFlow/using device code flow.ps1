# Connect using device code flow with required permissions
Connect-MgGraph `
    -UseDeviceCode `
    -Scopes 'User.Read.All', 'Group.ReadWrite.All', 'Directory.Read.All' `
    -ClientId '14d82eec-204b-4c2f-b7e8-296a70dab67e' # Default PowerShell client ID

# Verify connection and Context
"Connected to Microsoft Graph as: $((Get-MgContext).Account)"

(Get-MgContext).Scopes
(Get-MgContext).TokenCredentialType

Disconnect-MgGraph

#region tokentactics

## https://github.com/f-bader/TokenTacticsV2
Set-Location C:\temp\DeviceCode\
git clone https://github.com/f-bader/TokenTacticsV2.git
Import-Module .\TokenTactics.psd1 -Verbose -Force
get-command -Module TokenTactics

## example 1
Invoke-RefreshToMSGraphToken -Domain 'sc3210.onmicrosoft.com'
Connect-MgGraph -AccessToken $MSGraphToken.access_token -Scopes 'User.Read.All', 'Group.ReadWrite.All'

## example 2
Get-AzureAuthorizationCode -UseCAE
[string]$RequestURL = Get-Clipboard
Get-AzureTokenFromAuthorizationCode -UseCAE -Client 'MSGraph' -RequestURL $RequestURL -Verbose
RefreshTo-MSGraphToken -refreshToken $MSGraphToken.refresh_token -Domain $tokendomain -Verbose

#endregion tokentactics

#region SigninLogs
$filter = "createdDateTime ge $((Get-Date).AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ssZ"))"
$AuditRecords = Get-MgBetaAuditLogSignIn -Filter $filter -All

$results =
$AuditRecords | Where-Object { $_.AuthenticationProtocol -eq 'devicecode' } | ForEach-Object {
    [PSCustomObject]@{
        UserPrincipalName                = $_.userPrincipalName
        AuthenticationProtocol           = $_.AuthenticationProtocol
        OriginalTransferMethod           = $_.originalTransferMethod
        signInEventTypes                 = $_.signInEventTypes -join ', '
        App                              = $_.AppDisplayName
        IPAddress                        = $_.ipAddress
        Status                           = $_.status.errorCode
        DateTime                         = $_.createdDateTime
        AppliedConditionalAccessPolicies = $_.AppliedConditionalAccessPolicies.DisplayName -join ', '
        Location                         = $_.location.city + ", " + $_.location.countryOrRegion
        ClientAppUsed                    = $_.clientAppUsed
        RiskDetail                       = $_.riskDetail
    }
}
$results | ogv

#endregion SigninLogs