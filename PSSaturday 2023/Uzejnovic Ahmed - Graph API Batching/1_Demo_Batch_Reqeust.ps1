Import-Module ".\PSSAT\DEMO_MODULES_BATCHNG.psm1" -DisableNameChecking -Force    -DisableNameChecking -Force    


$TenantName = "tenant.onmicrosoft.com"
$ClientId = ""
$ClientSecret = Get-Secret -Name mysecretstore -AsPlainText

$token = Request-AccessToken -TenantName "$TenantName" -ClientId "$ClientId" -ClientSecret "$ClientSecret"

$headers = @{

  "Authorization" = "Bearer $($token)"
  "Content-type"  = "application/json;charset=utf-8"
}


# get user     User.Read.All, User.ReadWrite.All, Directory.Read.All, Directory.ReadWrite.All
#  https://graph.microsoft.com/v1.0/users/87d349ed-44d7-43e1-9a83-5f2406dee5bd

# get group    GroupMember.Read.All, Group.Read.All, Directory.Read.All, Group.ReadWrite.All, Directory.ReadWrite.All 
#GET https://graph.microsoft.com/v1.0/groups/02bd9fd6-8f93-4758-87c3-1fb73740a315
    
# get drive    Files.Read.All, Files.ReadWrite.All, Sites.Read.All, Sites.ReadWrite.All
#GET https://graph.microsoft.com/v1.0/users/{idOrUserPrincipalName}/drive

# get teams   Team.ReadBasic.All, TeamSettings.Read.All, TeamSettings.ReadWrite.All   
#GET https://graph.microsoft.com/v1.0/teams/893075dd-2487-4122-925f-022c42e20265

#"dependsOn": [ "1" ],
#?test429=true


$batchrequest = @"

    {
        "requests": [
          {
            "id": "1",
            "method": "GET",
            "url": "/users/1c9f8606-c6f5-4865-a58f-f5a6aa3ce03c"
          },
          {
            "id": "2",
            "method": "GET",
            "url": "/groups/f18901f7-3c90-486e-9f29-1a87aeae5e16"
          },
          {
            "id": "3",
            "method": "GET",
            "url": "/users/1c9f8606-c6f5-4865-a58f-f5a6aa3ce03c/drive"
          },
          {
            "id": "4",
            "method": "GET",
            "url": "/teams"
          }
        ]
      }

"@


#$batchinbytes = [System.Text.Encoding]::UTF8.GetBytes($batchrequest)
#$BatchRequestResult = Invoke-RestMethod -Method Post -Uri $batchUrl -Body $batchinbytes -Headers $headers



$batchurl = "https://graph.microsoft.com/v1.0/`$batch"

$BatchRequestResult = $null

$BatchRequestResult = Invoke-RestMethod -Method Post -Uri $batchUrl -Body $batchrequest -Headers $headers

$BatchRequestResult.responses | select id, status

$BatchRequestResult.responses.Body







