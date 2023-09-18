#region was kommt raus?
(Get-ADUSer -Filter *).Count
(Get-ADUSer -Filter {name -eq "krbtgt"}).Count
#endregion
#region Erklärung
(Get-ADUSer -Filter *).GetType()
(Get-ADUSer -Filter {name -eq "krbtgt"}).GetType()
#endregion