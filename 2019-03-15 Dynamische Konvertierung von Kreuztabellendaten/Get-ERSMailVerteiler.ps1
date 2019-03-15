function Get-ERSMailVerteiler
{
    <#
            .Synopsis
            Zuordnung von LehrerAccounts zu "ERS-Gruppen"
            .DESCRIPTION
            List eine Excel Mappe mit Infos über die Zuordnung von LehrerAccounts und deren Gruppenmitgliedschaft aus "ERS-Gruppen" aus
            .EXAMPLE
            Get-ERS-MailVerteiler -path "D:\Daten\ERS\_Office365\Eugen-Reintjes-Schule\ERS365-Info - Dokumente\ERS-MailGruppen\CrossTable.xlsx"
            .EXAMPLE
            Ein weiteres Beispiel für die Verwendung dieses Cmdlets
    #>
    [CmdletBinding()]
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        $path
    )

    Begin
    {
    }
    Process
    {
        
        
        $ExcelFile = New-Excel -Path $path
        $Workbook = Get-Workbook $ExcelFile
        $WorkSheet = $Workbook | Get-Worksheet -Name Zuordnung-LK-Gruppe
        # ausgefüllter Bereich in dem Excel Datenblatt
        $coordinates = $WorkSheet.Dimension.Address
        #$coordinates
        
        #exit

        $ExcelCrossData = Get-CellValue -Path $Path -WorkSheetName Zuordnung-LK-Gruppe -Coordinates $coordinates

        #$ExcelCrossData
        
        #exit
        foreach ($ERSExcelListenEntry in $ExcelCrossData)
        {
            $ERSExcelGruppen = $ERSExcelListenEntry | gm | Where-Object {$_.Name -like 'ERS*'} | Select-Object -expandProperty Name
            $out=$Null
            for ($i = 0; $i -lt $ERSExcelGruppen.count ; $i++)
            { 
                $temp = $ERSExcelListenEntry | Select-Object -ExpandProperty $ERSExcelGruppen[$i]
                if($temp.length -ne 0) {$temp=$temp.trim()}
                [array]$out += $temp
                
                
            }
            $ERSExcelListenEntry = $ERSExcelListenEntry | Select-Object O365Mail
            Add-Member -InputObject $ERSExcelListenEntry -MemberType NoteProperty -name MailVerteiler -Value $out  
        
            Write-output $ERSExcelListenEntry
        }
      
    }

    End
    {
    }
}


Get-ERSMailVerteiler -path "$PSScriptRoot\ERSMailGruppen.xlsx"