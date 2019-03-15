function Get-ExcelCrossTable-As-Objects
{
    <#
            .Synopsis
            Conversion of "Crosstable" Data from Excel or CSV into strucrured PowerShell Objects
            .DESCRIPTION
            This Cmd-Let function can be used to convert "non normalized" Excel Data into PS Objects including Subobject-Arrays
            Hint: The Excel Data should be previously prepared to fit the conditions of this Cmd-Let function. There must be a set of "regular" Data (Attributes) in the rows of the Excel Datasheet AND eventually more Sets of
            Data, that are "connected" to the "regular" data. All these datacollumns must beginn with a cerain prefix, which is used as a parameter by the Cms-Let function. The "pk"-Field should server as a primary key, which
            identifies each row unambiguously. The prefix "pk" stands for primary key and is "only" a convention. The connected Array of subitems automatically gets an attribut named "fk".... with the same value as the "pk" field.
            The default name of the array of Subitems is "SubItemObject"    
            .EXAMPLE
            Get-ExcelCrossTable-As-Object -path "$PSScriptRoot\CrossTable.xlsx" -prefix 'CT' -subobjektname 'Bestellungen' -pk_name 'pk_BestellID'
            
    #>
    [CmdletBinding()]
    Param
    (
        # path to the Excel file
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,Position=0)]
        $path,
        # prefix of the rows that contain "prefixed" Data in the Excel file
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,Position=1)]
        [string]$prefix,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,Position=2)]
        # name of the coumumn thas serves as primary key
        [string]$pk_name,
        # name of the Attribute of the SubItem ObjectArray      
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false,Position=3)]
        [string]$subobjektname = "SubItemObject"

    )
    Process
    {
        $ExcelFile = New-Excel -Path $path
        $Workbook = Get-Workbook $ExcelFile
        $WorkSheet = $Workbook | Get-Worksheet -Name CrossData
        # ausgefüllter Bereich in dem Excel Datenblatt
        $coordinates = $WorkSheet.Dimension.Address
        #$coordinates
        
        $ExcelCrossData = Get-CellValue -Path $Path -WorkSheetName CrossData -Coordinates $coordinates

         # Anzahl der Zeilen = Anzahl der MainData Datensätze
        $NumberOfRows = $ExcelCrossData.count
        
        # Namen der Attribute der MainData
        $ExcelMainItemNames = $ExcelCrossData[0] | gm | Where-Object {$_.Name -notlike $prefix + '*' -and $_.Membertype -ne 'Method'} | Select-Object -ExpandProperty Name
        
        # Anzahl der Zeilen = Anzahl der MainData Datensätze 
        $ExcelMainItemNamesCount = $ExcelMainItemNames.count

        # Namen der SubItems MIT Prefix
        $ExcelSubItemNamesPrefix = $ExcelCrossData[0] | gm | Where-Object {$_.Name -like $prefix + '*' -and $_.Membertype -ne 'Method'} | Select-Object  -ExpandProperty Name
        
        # Liefert Namen der SubItemsAttribute OHNE Prefix und Anzahl der SubItemAttribute
        $ExcelSubItemNamesPur = ($ExcelSubItemNamesPrefix -split '-') | Where-Object {$_ -notlike $prefix + '*'} | Group-Object #| Select-Object -ExpandProperty Name
        #$ExcelSubItemNamesPur
        
        
        #Gesamtzahl der SubItems
        $ExcelSubItemNamesCount = $ExcelSubItemNamesPrefix.count

        # Namen der SubItems OHNE Prefix
        $ExcelSubItemsAttributNames = $ExcelSubItemNamesPur | Select-Object -ExpandProperty Name
        
        # Anzahl der SubItemObjekte
        $ExcelSubItemsObjectCount = $ExcelSubItemNamesPur | Select-Object -ExpandProperty Count -Unique
        
        # Anzahl SubObjekte je Zeile
        $SubObjectAttributCount = $ExcelSubItemNamesCount/$ExcelSubItemsObjectCount

        <#
        #Testausgaben
        "Name der HauptAttribute: $ExcelMainItemNames"
        "Anzahl der HauptAttribute: $ExcelMainItemNamesCount"
        "Namen der SubItems MIT Prefix: $ExcelSubItemNamesPrefix"
        "Namen der SubItems OHNE Prefix: $ExcelSubItemsAttributNames"
        "Anzahl der gesamten SubElemente = $ExcelSubItemNamesCount"
        "Anzahl der SubObjekte = $ExcelSubItemsObjectCount"
        "Anzahl der SubObjektAttribute = $SubObjectAttributCount"
        #exit
        #>
        <#
        #$ExcelMainObjects = $ExcelCrossData | Select-Object -property $ExcelMainItemNames
        #$ExcelMainObjects

        #$ExcelMainObjects = $ExcelCrossData[1] | Select-Object -property $ExcelMainItemNames
        #$ExcelMainObjects
        #>
        
        
            # Lauf durch alle Zeilen der Rohdaten
            for ($i = 0; $i -lt $NumberOfRows; $i++)
            { 
                # ObjectArray für die SubObjekte
                $outObjectArray = @()
                # Schleife durch die SubObjekte
                $Start = 0   
                for ($p =0 ; $p -lt $ExcelSubItemsObjectCount; $p++)
                {
                    # Zähler für erste Subobjekt
                      
                    $out_object = New-Object -TypeName PSObject
                    
                    # Schleife durch die Attribute der SubObjekte
                    for ($o = $start; $o -lt ($SubObjectAttributCount+$start) ; $o++)
                    {
                        if ($($ExcelCrossData[$i].($ExcelSubItemNamesPrefix[$k+$o])) -ne $Null)
                        {
                            # FK Wert als erstes Attribut EINMAL hinzufügen
                            if ($o -eq $start)
                            {
                            # Extrahieren des "Primärschlüssels" (Name des FK und dessen Wert)
                            $ID = $ExcelCrossData[$i] | Select-Object -ExpandProperty $pk_name # Wert des PK 
                            $fk_name = $pk_name -replace 'p','f' # Name des FK                    
                            $out_object | Add-Member -MemberType NoteProperty -Name $fk_name -Value $ID
                            }                          
                            $out_object | Add-Member  -MemberType NoteProperty -Name $($(($($ExcelSubItemNamesPrefix[$k+$o]) -split '-')[1])) -Value $($ExcelCrossData[$i].($ExcelSubItemNamesPrefix[$k+$o]))
                        } 
                    }
                    $Start= $Start + $SubObjectAttributCount 
                    #"Start = $Start"
                    $outObjectArray += $out_object
                }
                 $ExcelMainObject = $ExcelCrossData[$i] | Select-Object -property $ExcelMainItemNames
                 $ExcelTotalOjekt = $ExcelMainObject | Add-Member -MemberType NoteProperty -Name $subobjektname -Value $outObjectArray -PassThru
                 $ExcelTotalOjekt
            }   
}
}


$obe = Get-ExcelCrossTable-As-Objects -path "$PSScriptRoot\CrossTable.xlsx" -prefix 'CT' -subobjektname 'Bestellungen' -pk_name 'pk_BestellID'
$obe | Out-GridView