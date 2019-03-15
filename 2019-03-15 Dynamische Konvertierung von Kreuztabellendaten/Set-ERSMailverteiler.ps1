function Set-ERSMailverteiler{
    param(  
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('Lehrerliste')]
        [PSObject]$Lehrer
    ) 

    process {
               
        $Suchmail = $Lehrer.O365Mail
        
        Write-Host "Bearbeite gerade: $Suchmail"
        $ADLehrer=Get-Aduser -Filter "UserPrincipalName -eq '$Suchmail'"
       
        $LehrerGruppen=Get-ADPrincipalGroupMembership $ADLehrer
       
        # alten ERS Mailverteiler für Benutzer löschen
        $LehrerGruppen | where {$_.name -like 'ERS-*'}   |foreach { Remove-ADGroupmember -Identity $_.name -Members $ADLehrer.samaccountname -Confirm:$false}
        
        # Liste der Gruppen für dem Benutzer in der Pipeline herausfiltern
        $Mailverteiler = $Lehrer | Select-Object -ExpandProperty MailVerteiler
       
        # Kommentar für echbtrieb rausnehmem
        Add-ADPrincipalGroupMembership -Identity $ADLehrer.samaccountname -MemberOf $Mailverteiler
       
                
    }
}
