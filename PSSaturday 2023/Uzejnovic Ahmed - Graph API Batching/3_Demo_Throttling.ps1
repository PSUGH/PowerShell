Import-Module ".\PSSAT\DEMO_MODULES_BATCHNG.psm1" -DisableNameChecking -Force    -DisableNameChecking -Force


$TenantName = "tenant.onmicrosoft.com"
$ClientId = ""
$ClientSecret = Get-Secret -Name mysecretstore -AsPlainText

$token = Request-AccessToken -TenantName "$TenantName" -ClientId "$ClientId" -ClientSecret "$ClientSecret"
    

$headers = @{

  "Authorization" = "Bearer $($token)"
  "Content-type"  = "application/json;charset=utf-8"
}




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
            "dependsOn": [ "1" ],
            "method": "GET",
            "url": "/groups/f18901f7-3c90-486e-9f29-1a87aeae5e16"
          },
          {
            "id": "3",
            "dependsOn": [ "2" ],
            "method": "GET",
            "url": "/users/1c9f8606-c6f5-4865-a58f-f5a6aa3ce03c/drive?test429=true"
          },
          {
            "id": "4",
            "dependsOn": [ "3" ],
            "method": "GET",
            "url": "/teams"
          },
          {
            "id": "5",
            "dependsOn": [ "4" ],
            "method": "GET",
            "url": "/users/1c9f8606-c6f5-4865-a58f-f5a6aa3ce03c"
          }
        ]
      }

"@


#$batchinbytes = [System.Text.Encoding]::UTF8.GetBytes($batchrequest)
#$BatchRequestResult = Invoke-RestMethod -Method Post -Uri $batchUrl -Body $batchinbytes -Headers $headers



$batchurl = "https://graph.microsoft.com/v1.0/`$batch"
$BatchRequestResult = $null
$BatchRequestResult = Invoke-RestMethod -Method Post -Uri $batchUrl -Body $batchrequest -Headers $headers


$BatchRequestResult.responses | Select-Object id, status

($BatchRequestResult.responses | Where-Object { $_.id -eq 3 }).headers

($BatchRequestResult.responses | Where-Object { $_.id -eq 4 }).body






