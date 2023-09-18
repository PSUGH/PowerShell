#region wer bin ich und wo komme ich her?
$userSAM = [Environment]::UserName
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().GetDirectoryEntry()
#endregion
#region finde mich!
$searcher = New-Object System.DirectoryServices.DirectorySearcher($domain)
$searcher.SearchScope = [System.DirectoryServices.SearchScope]::Subtree
$searcher.Filter = ('(sAMAccountName={0})' -f $userSAM)
$null = $searcher.PropertiesToLoad.Add('mail')
$searchResult = $searcher.FindOne()
#endregion
#region wie ist meine email-adresse?
$searchResult.Properties['mail']
#endregion
#region ist das alles?
$searchResult.Properties['mail'].Count
#endregion
#region und nu?
$searchResult.Properties['mail'][0]
#endregion