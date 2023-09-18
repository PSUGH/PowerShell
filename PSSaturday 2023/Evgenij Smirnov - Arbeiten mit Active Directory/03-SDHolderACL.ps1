$path = 'CN=AdminSDHolder,CN=System,{0}'

#region AD Module
Import-Module ActiveDirectory
$domain = Get-ADDomain
$ldapPath = $path -f $domain.DistinguishedName
$acl = Get-ACL -Path "AD:\$ldapPath"
$acl.GetType()
#endregion

#region DirectoryServices
$domainDN = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().GetDirectoryEntry().distinguishedName[0]
$ldapPath = $path -f $domainDN
$dsE = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$ldapPath")
$acl = $dsE.ObjectSecurity
$acl.GetType()
#endregion