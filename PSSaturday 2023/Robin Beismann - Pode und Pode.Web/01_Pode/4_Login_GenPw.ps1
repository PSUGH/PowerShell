function ConvertTo-SHA256([string]$String)
{
    $SHA256 = New-Object System.Security.Cryptography.SHA256Managed
    $SHA256Hash = $SHA256.ComputeHash([Text.Encoding]::ASCII.GetBytes($String))
    $SHA256HashString = [Convert]::ToBase64String($SHA256Hash)
    return $SHA256HashString
}

ConvertTo-SHA256 -String "test"