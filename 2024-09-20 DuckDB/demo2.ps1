$dbpath = 'C:\temp\duckdb\demo2.db'

$path = 'C:\temp\duckdb'
$conn = New-DuckDBConnection $dbpath

#region blacklists and whitelists
$blacklistfolder = join-path -Path $path -ChildPath 'blacklists'
$whitelistfolder = join-path -Path $path -ChildPath 'whitelists'

foreach ($file in Get-ChildItem -Path $blacklistfolder -Recurse -File) {
    $filename = $file.FullName 
    $table = $file.basename.Replace('-', '')
    $qry = "CREATE TABLE $table AS SELECT * FROM read_csv_auto('$filename');"
    $conn.sql($qry)
} 

$tabs = $conn.sql('SELECT * FROM pg_catalog.pg_tables;')  
$tabs.tablename
#endregion blacklists and whitelists

#region process json input
$inputobject = join-path -Path $path -ChildPath 'InteractiveSignIns.json'

$rawdata = $InputObject | Open-JsonFile
$Results = @()
$Results = 
ForEach ($Record in $rawdata) {
    [PSCustomObject]@{
        "Id"                             = $Record.Id # The identifier representing the sign-in activity.
        "CreatedDateTime"                = ($Record | Select-Object -ExpandProperty CreatedDateTime).ToString("yyyy-MM-dd HH:mm:ss")
        "UserDisplayName"                = $Record.UserDisplayName # The display name of the user.
        "UserPrincipalName"              = $Record.UserPrincipalName # The UPN of the user.
        "UserId"                         = $Record.UserId # The identifier of the user.
        "AppDisplayName"                 = $Record.AppDisplayName # The application name displayed in the Microsoft Entra admin center.
        "AppId"                          = $Record.AppId # The application identifier in Microsoft Entra ID.
        "ClientAppUsed"                  = $Record.ClientAppUsed # The legacy client used for sign-in activity.
        "IpAddress"                      = $Record.IpAddress # The IP address of the client from where the sign-in occurred.
        "ASN"                            = $Record.AutonomousSystemNumber # The Autonomous System Number (ASN) of the network used by the actor.
        "IPAddressFromResourceProvider"  = $Record.IPAddressFromResourceProvider # The IP address a user used to reach a resource provider, used to determine Conditional Access compliance for some policies. For example, when a user interacts with Exchange Online, the IP address that Microsoft Exchange receives from the user can be recorded here. This value is often null.
        "City"                           = $Record | Select-Object -ExpandProperty Location | Select-Object -ExpandProperty City # The city from where the sign-in occurred.
        "State"                          = $Record | Select-Object -ExpandProperty Location | Select-Object -ExpandProperty State # The state from where the sign-in occurred.
        "CountryOrRegion"                = $Record | Select-Object -ExpandProperty Location | Select-Object -ExpandProperty CountryOrRegion # The two letter country code from where the sign-in occurred.
        "Latitude"                       = $Record | Select-Object -ExpandProperty Location | Select-Object -ExpandProperty GeoCoordinates | Select-Object -ExpandProperty Latitude
        "Longitude"                      = $Record | Select-Object -ExpandProperty Location | Select-Object -ExpandProperty GeoCoordinates | Select-Object -ExpandProperty Longitude
        "AuthenticationRequirement"      = $Record.AuthenticationRequirement # This holds the highest level of authentication needed through all the sign-in steps, for sign-in to succeed.
        "SignInEventTypes"               = $Record | Select-Object -ExpandProperty SignInEventTypes # Indicates the category of sign in that the event represents.
        "AuthenticationMethodsUsed"      = $Record | Select-Object -ExpandProperty AuthenticationMethodsUsed # The authentication methods used.

        # Status - The sign-in status. Includes the error code and description of the error (for a sign-in failure).
        # https://learn.microsoft.com/nb-no/graph/api/resources/signinstatus?view=graph-rest-beta
        "ErrorCode"                      = $Record | Select-Object -ExpandProperty Status | Select-Object -ExpandProperty ErrorCode # Provides the 5-6 digit error code that's generated during a sign-in failure.
        "FailureReason"                  = $Record | Select-Object -ExpandProperty Status | Select-Object -ExpandProperty FailureReason # Provides the error message or the reason for failure for the corresponding sign-in activity.
        "AdditionalDetails"              = $Record | Select-Object -ExpandProperty Status | Select-Object -ExpandProperty AdditionalDetails # Provides additional details on the sign-in activity.

        # AuthenticationDetails - The result of the authentication attempt and more details on the authentication method.
        # https://learn.microsoft.com/nb-no/graph/api/resources/authenticationdetail?view=graph-rest-beta
        "AuthenticationMethod"           = ($Record | Select-Object -ExpandProperty AuthenticationDetails | Select-Object -ExpandProperty AuthenticationMethod -Unique) -join ", " # The type of authentication method used to perform this step of authentication.
        "AuthenticationMethodDetail"     = ($Record | Select-Object -ExpandProperty AuthenticationDetails | Select-Object -ExpandProperty AuthenticationMethodDetail -Unique) -join ", " # Details about the authentication method used to perform this authentication step.
        "AuthenticationStepDateTime"     = ($Record | Select-Object -ExpandProperty AuthenticationDetails | Select-Object -ExpandProperty AuthenticationStepDateTime -Unique | ForEach-Object { ($_).ToString("yyyy-MM-dd HH:mm:ss") }) -join ", " # Represents date and time information using ISO 8601 format and is always in UTC time.
        "AuthenticationStepRequirement"  = ($Record | Select-Object -ExpandProperty AuthenticationDetails | Select-Object -ExpandProperty AuthenticationStepRequirement -Unique) -join ", " # The step of authentication that this satisfied. 
        "AuthenticationStepResultDetail" = ($Record | Select-Object -ExpandProperty AuthenticationDetails | Select-Object -ExpandProperty AuthenticationStepResultDetail -Unique) -join ", " # Details about why the step succeeded or failed. 
        "Succeeded"                      = ($Record | Select-Object -ExpandProperty AuthenticationDetails | Select-Object -ExpandProperty Succeeded -Unique) -join ", " # Indicates the status of the authentication step.

        # AuthenticationProcessingDetails - More authentication processing details, such as the agent name for PTA and PHS, or a server or farm name for federated authentication.
        "Domain Hint Present"            = ($Record | Select-Object -ExpandProperty AuthenticationProcessingDetails | Where-Object { $_.Key -eq 'Domain Hint Present' }).Value
        "Is CAE Token"                   = ($Record | Select-Object -ExpandProperty AuthenticationProcessingDetails | Where-Object { $_.Key -eq 'Is CAE Token' }).Value
        "Login Hint Present"             = ($Record | Select-Object -ExpandProperty AuthenticationProcessingDetails | Where-Object { $_.Key -eq 'Login Hint Present' }).Value
        "Oauth Scope Info"               = ($Record | Select-Object -ExpandProperty AuthenticationProcessingDetails | Where-Object { $_.Key -eq 'Oauth Scope Info' }).Value
        "Root Key Type"                  = ($Record | Select-Object -ExpandProperty AuthenticationProcessingDetails | Where-Object { $_.Key -eq 'Root Key Type' }).Value

        "ClientCredentialType"           = $Record.ClientCredentialType # Describes the credential type that a user client or service principal provided to Microsoft Entra ID to authenticate itself. You can review this property to track and eliminate less secure credential types or to watch for clients and service principals using anomalous credential types.
        "ConditionalAccessStatus"        = $Record.ConditionalAccessStatus # The status of the conditional access policy triggered.
        "CorrelationId"                  = $Record.CorrelationId # The identifier that's sent from the client when sign-in is initiated.
        "IncomingTokenType"              = $Record.IncomingTokenType # Indicates the token types that were presented to Microsoft Entra ID to authenticate the actor in the sign in. 
        "OriginalRequestId"              = $Record.OriginalRequestId # The request identifier of the first request in the authentication sequence.
        "IsInteractive"                  = $Record.IsInteractive # Indicates whether a user sign in is interactive. In interactive sign in, the user provides an authentication factor to Microsoft Entra ID. These factors include passwords, responses to MFA challenges, biometric factors, or QR codes that a user provides to Microsoft Entra ID or an associated app. In non-interactive sign in, the user doesn't provide an authentication factor. Instead, the client app uses a token or code to authenticate or access a resource on behalf of a user. Non-interactive sign ins are commonly used for a client to sign in on a user's behalf in a process transparent to the user.
        "ProcessingTimeInMilliseconds"   = $Record.ProcessingTimeInMilliseconds # The request processing time in milliseconds in AD STS.
        "ResourceDisplayName"            = $Record.ResourceDisplayName # The name of the resource that the user signed in to.
        "ResourceId"                     = $Record.ResourceId # The identifier of the resource that the user signed in to.
        "ResourceServicePrincipalId"     = $Record.ResourceServicePrincipalId # The identifier of the service principal representing the target resource in the sign-in event.
        "ResourceTenantId"               = $Record.ResourceTenantId # The tenant identifier of the resource referenced in the sign in.
        "RiskDetail"                     = $Record.RiskDetail # The reason behind a specific state of a risky user, sign-in, or a risk event.
        "RiskEventTypes_v2"              = $Record | Select-Object -ExpandProperty RiskEventTypes_v2 # The list of risk event types associated with the sign-in.
        "RiskLevelAggregated"            = $Record.RiskLevelAggregated # The aggregated risk level. The value hidden means the user or sign-in wasn't enabled for Microsoft Entra ID Protection.
        "RiskLevelDuringSignIn"          = $Record.RiskLevelDuringSignIn # The risk level during sign-in. The value hidden means the user or sign-in wasn't enabled for Microsoft Entra ID Protection.
        "RiskState"                      = $Record.RiskState # The risk state of a risky user, sign-in, or a risk event.
        "SignInTokenProtectionStatus"    = $Record.SignInTokenProtectionStatus # oken protection creates a cryptographically secure tie between the token and the device it is issued to. This field indicates whether the signin token was bound to the device or not.
        "TokenIssuerName"                = $Record.TokenIssuerName # The name of the identity provider.
        "TokenIssuerType"                = $Record.TokenIssuerType # The type of identity provider.
        "UniqueTokenIdentifier"          = $Record.UniqueTokenIdentifier # A unique base64 encoded request identifier used to track tokens issued by Microsoft Entra ID as they're redeemed at resource providers.
        "UserAgent"                      = $Record.UserAgent # The user agent information related to sign-in.
        "UserType"                       = $Record | Select-Object -ExpandProperty UserType | ForEach-Object { $_.Replace("member", "Member") } | ForEach-Object { $_.Replace("guest", "Guest") } # Identifies whether the user is a member or guest in the tenant.
        "AuthenticationProtocol"         = $Record.AuthenticationProtocol # Lists the protocol type or grant type used in the authentication.
        "OriginalTransferMethod"         = $Record.OriginalTransferMethod # Transfer method used to initiate a session throughout all subsequent request.

        # MfaDetail - This property is deprecated.
        "AuthMethod"                     = $Record | Select-Object -ExpandProperty MfaDetail | Select-Object -ExpandProperty AuthMethod
        "AuthDetail"                     = $Record | Select-Object -ExpandProperty MfaDetail | Select-Object -ExpandProperty AuthDetail

        # DeviceDetail - The device information from where the sign-in occurred. Includes information such as deviceId, OS, and browser.
        # https://learn.microsoft.com/nb-no/graph/api/resources/devicedetail?view=graph-rest-beta
        "DeviceId"                       = $Record | Select-Object -ExpandProperty DeviceDetail | Select-Object -ExpandProperty DeviceId # Refers to the UniqueID of the device used for signing-in.
        "DisplayName"                    = $Record | Select-Object -ExpandProperty DeviceDetail | Select-Object -ExpandProperty DisplayName # Refers to the name of the device used for signing-in.
        "OperatingSystem"                = $Record | Select-Object -ExpandProperty DeviceDetail | Select-Object -ExpandProperty OperatingSystem # Indicates the OS name and version used for signing-in.
        "Browser"                        = $Record | Select-Object -ExpandProperty DeviceDetail | Select-Object -ExpandProperty Browser # Indicates the browser information of the used for signing-in.
        "IsCompliant"                    = $Record | Select-Object -ExpandProperty DeviceDetail | Select-Object -ExpandProperty IsCompliant # Indicates whether the device is compliant or not.
        "IsManaged"                      = $Record | Select-Object -ExpandProperty DeviceDetail | Select-Object -ExpandProperty IsManaged # Indicates if the device is managed or not.
        "TrustType"                      = $Record | Select-Object -ExpandProperty DeviceDetail | Select-Object -ExpandProperty TrustType # Indicates information on whether the signed-in device is Workplace Joined, AzureAD Joined, Domain Joined.

        # NetworkLocationDetails - The network location details including the type of network used and its names.
        # https://learn.microsoft.com/nb-no/graph/api/resources/networklocationdetail?view=graph-rest-beta
        "NetworkType"                    = $Record | Select-Object -ExpandProperty NetworkLocationDetails | Select-Object -ExpandProperty NetworkType # Provides the type of network used when signing in.
        "NetworkNames"                   = $Record | Select-Object -ExpandProperty NetworkLocationDetails | Select-Object -ExpandProperty NetworkNames # Provides the name of the network used when signing in.
    }
}
#endregion process json input

# TODO: find a better way to handle this
$data = 'C:\temp\duckdb\results.csv'
$Results | Export-Csv -Path $data -NoTypeInformation -Delimiter ';'

# import the json data
$import = "CREATE TABLE results AS FROM read_csv('$data');"
$conn.sql($import)
$conn.sql('SELECT * FROM results limit 5;')

# check for tables
$tabs = $conn.sql('SELECT * FROM pg_catalog.pg_tables;')  
$tabs.tablename

# import error codes
$errordata = join-path -Path $path -ChildPath 'Config\Status.csv'
$import = "CREATE OR REPLACE TABLE errorstates AS FROM read_csv('$errordata');"
$conn.sql($import)
$conn.sql('SELECT * FROM errorstates;')

# check for login errors and codes
$qry = @"
SELECT res.Id,res.CreatedDateTime, res.UserPrincipalName, err.* FROM results as res
LEFT JOIN errorstates as err
ON res.ErrorCode = err.ErrorCode
WHERE res.ErrorCode <> 0; 
"@
$errors = $conn.sql($qry)


$qry = @"
SELECT res.ClientAppUsed, err.Status, count(*) FROM results as res
LEFT JOIN errorstates as err
ON res.ErrorCode = err.ErrorCode
group by res.ClientAppUsed,err.Status;
"@
$ClientAppUsed = $conn.sql($qry)
