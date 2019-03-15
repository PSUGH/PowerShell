# Steuerfunktion für den Teamgruppensync excel-AD
function Start-ERSMailverteiler
{
    $Itteam_Liste = "'Becker@ers-hm.de', 'Schrader@ers-hm.de', 'Goette_M@ers-hm.de', 'Juergens_H@ers-hm.de', 'Vogt_O@ers-hm.de', 'Schmidtke_G@ers-hm.de', 'Rose_A@ers-hm.de', 'Kammeyer_R@ers-hm.de', 'Olejniczak_M@ers-hm.de', 'Hoelscher_S@ers-hm.de', 'Schulze_D@ers-hm.de', 'Wilp_G@ers-hm.de', 'Lappe_T@ers-hm.de', 'Dylong_J@ers-hm.de', 'Lam_H@ers-hm.de'"
    

    #$Mail = Get-ERS-MailVerteiler -path "C:\O365OneDrive\Eugen-Reintjes-Schule\ERS365-Info - ERS-MailGruppen\ERSMailGruppen.xlsx" 
    
    $Mail = Get-ERS-MailVerteiler -path "C:\O365OneDrive\Eugen-Reintjes-Schule\ERS365-Info - ERS-MailGruppen\ERSMailGruppen.xlsx"  | where-Object {$_.Mailverteiler -ne $Null } #-and $_.O365Mail -in 'koch_r@ers-hm.de', 'Schrader@ers-hm.de', 'Goette_M@ers-hm.de' , 'Juergens_H@ers-hm.de', 'Vogt_O@ers-hm.de', 'Schmidtke_G@ers-hm.de', 'Rose_A@ers-hm.de', 'Kammeyer_R@ers-hm.de', 'Olejniczak_M@ers-hm.de', 'Hoelscher_S@ers-hm.de', 'Schulze_D@ers-hm.de', 'Wilp_G@ers-hm.de', 'Lappe_T@ers-hm.de', 'Dylong_J@ers-hm.de', 'Lam_H@ers-hm.de'}

    #$mail #| Select-Object -ExpandProperty Mailverteiler | out-file -FilePath C:\O365MailPS\result.csv
    
    $mail | Set-ERSMailverteiler
}





     $Mail = Get-ERS-MailVerteiler -path "C:\O365OneDrive\Eugen-Reintjes-Schule\ERS365-Info - ERS-MailGruppen\ERSMailGruppen.xlsx"  | where-Object {$_.Mailverteiler -ne $Null } #-and $_.O365Mail -in 'koch_r@ers-hm.de', 'Schrader@ers-hm.de', 'Goette_M@ers-hm.de' , 'Juergens_H@ers-hm.de', 'Vogt_O@ers-hm.de', 'Schmidtke_G@ers-hm.de', 'Rose_A@ers-hm.de', 'Kammeyer_R@ers-hm.de', 'Olejniczak_M@ers-hm.de', 'Hoelscher_S@ers-hm.de', 'Schulze_D@ers-hm.de', 'Wilp_G@ers-hm.de', 'Lappe_T@ers-hm.de', 'Dylong_J@ers-hm.de', 'Lam_H@ers-hm.de'}




