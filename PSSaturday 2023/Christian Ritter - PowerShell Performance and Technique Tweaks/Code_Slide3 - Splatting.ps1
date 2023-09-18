# Title: Splatting
break



#Region The Bad

    New-ADUser -Name "John Doe" -GivenName "John" -Surname "Doe" -DisplayName "John Doe" -SamAccountName "johnd" -UserPrincipalName "johnd@example.com" -Description "New user account for John Doe" -Path "OU=Users,DC=example,DC=com" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) -Enabled $true -Office "123 Main Street" -Title "Manager" -Department "IT" -Manager "CN=Manager User,OU=Users,DC=example,DC=com" -OfficePhone "555-123-4567" -City "New York" -State "NY" -PostalCode "10001" -Country "US" -EmailAddress "john.doe@example.com"

#EndRegion The Bad

break

#Region The Ugly

    New-ADUser -Name "John Doe" `
        -GivenName "John" `
        -Surname "Doe" `
        -DisplayName "John Doe" `
        -SamAccountName "johnd" `
        -UserPrincipalName "johnd@example.com" `
        -Description "New user account for John Doe" `
        -Path "OU=Users,DC=example,DC=com" `
        -AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) `
        -Enabled $true `
        -Office "123 Main Street" `
        -Title "Manager" `
        -Department "IT" `
        -Manager "CN=Manager User,OU=Users,DC=example,DC=com" `
        -OfficePhone "555-123-4567" `
        -City "New York" `
        -State "NY" `
        -PostalCode "10001" `
        -Country "US" `
        -EmailAddress "john.doe@example.com"


#EndRegion The Ugly

break

#Region The Good

    $newADUserSplat = @{
        Name = "John Doe"
        GivenName = "John"
        Surname = "Doe"
        DisplayName = "John Doe"
        SamAccountName = "johnd"
        UserPrincipalName = "johnd@example.com"
        Description = "New user account for John Doe"
        Path = "OU=Users,DC=example,DC=com"
        AccountPassword = (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force)
        Enabled = $true
        Office = "123 Main Street"
        Title = "Manager"
        Department = "IT"
        Manager = "CN=Manager User,OU=Users,DC=example,DC=com"
        OfficePhone = "555-123-4567"
        City = "New York"
        State = "NY"
        PostalCode = "10001"
        Country = "US"
        EmailAddress = "john.doe@example.com"
    }

    New-ADUser @newADUserSplat

#EndRegion The Good

break

#Region Bonus

    if($newADUserSplat['Givenname'] -eq 'Holger'){
        $newADUserSplat['HomePage'] = "https://pssat.de/"
    }

#EndRegion Bonus

break