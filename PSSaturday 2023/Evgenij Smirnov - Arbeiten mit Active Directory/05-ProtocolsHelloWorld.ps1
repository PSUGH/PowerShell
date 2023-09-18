$null = [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols")
#region vorbereitung der Suchanfrage
$domainDN = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().GetDirectoryEntry().distinguishedName[0]
$pdcE = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($pdcE)
$LDAPConnection.SessionOptions.ReferralChasing = [System.DirectoryServices.Protocols.ReferralChasingOptions]::All
$request = New-Object System.directoryServices.Protocols.SearchRequest($domainDN, "(samaccountname=test*)", [System.DirectoryServices.Protocols.SearchScope]::Subtree)
$null = $request.Attributes.Add("ntsecuritydescriptor")
$null = $request.Attributes.Add("name")
$null = $request.Attributes.Add("samaccountname")
$null = $request.Attributes.Add("msDS-ReplAttributeMetaData")
#endregion
#region Suchanfrage
$response = $LDAPConnection.SendRequest($request)
#endregion
#region Ergebnisse
foreach ($entry in $response.Entries) {
    $entry.Attributes
    #$entry.Attributes['samaccountname']
    #$entry.Attributes['samaccountname'][0]
}  
#endregion