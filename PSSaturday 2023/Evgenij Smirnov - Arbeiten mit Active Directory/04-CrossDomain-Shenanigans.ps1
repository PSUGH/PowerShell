#region AD Module
Import-Module ActiveDirectory
Get-ADUser -LDAPFilter '(samaccountname=test*)'
Get-ADUser -LDAPFilter '(samaccountname=test*)' -Server (Get-ADForest).Name
# ...aber nicht beide zusammen!!!
Get-ADGroup -Identity 'TEST USERS' | Get-ADGroupMember
#endregion

#region GC search
$dsE = New-Object System.DirectoryServices.DirectoryEntry("GC://$([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Forest)")
$dsE.RefreshCache()
$searcher = New-Object System.DirectoryServices.DirectorySearcher($dsE)
$searcher.ReferralChasing = [System.DirectoryServices.ReferralChasingOption]::All
$searcher.SearchScope = [System.DirectoryServices.SearchScope]::Subtree
$searcher.Filter = '(&(objectCategory=person)(samaccountname=test*))' 
$searcher.FindAll()

$searcher.Filter = '(&(objectCategory=group)(name=TEST USERS))' 
$group = $searcher.FindOne()
$group.Properties['member']
foreach ($member in $group.Properties['member']) {
    $memDE = New-Object System.DirectoryServices.DirectoryEntry("GC://$member")
    $memDE.RefreshCache()
    $memDE.displayName[0]
}
#endregion