# Install-Module universalDashboard

Start-UDDashboard -port 10000
Start-Process http://localhost:10000

Get-UDDashboard | Stop-UDDashboard

$Dashboard = New-UDDashboard -Title "ein Dashboard" -Content { 
    New-UDHeading -Text "Just a Dashboard" -Size 1
}

Start-UDDashboard -Dashboard $Dashboard
Get-UDDashboard | Stop-UDDashboard

$Dashboard2 = New-UDDashboard -Title "ein Dashboard" -Content { 
    # New-UDHeading -Text "ServerDaten" -Size 1
    New-UDChart -Title "Process Memory" -Endpoint {
        Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | Out-UDChartData -DataProperty WorkingSet -LabelProperty Name
    }
}

Start-UDDashboard -Dashboard $Dashboard2 -Port 10000 # -AutoReload
Start-Process http://localhost:10000
Get-UDDashboard | Stop-UDDashboard

$DashboardLayout = New-UDDashboard -Title Layout -Content {
    New-UDLayout -Columns 4 -Content {
        New-UDHeading -Text Eins -Size 1
        New-UDHeading -Text Zwei -Size 1
        New-UDHeading -Text Drei -Size 1
        New-UDHeading -Text vier -Size 1
    }
}
Start-UDDashboard -Dashboard $DashboardLayout -Port 10000 # -AutoReload
Start-Process http://localhost:10000
Get-UDDashboard | Stop-UDDashboard

$DashboardLayout2 = New-UDDashboard -Title Layout -Content {
    New-UDRow -Columns {
        New-UDColumn -Smallsize 6 -Content { # Die Standardbreite einer Seite ist 12
            New-UDCard -Title "Size 6"
        }
        New-UDColumn -Smallsize 6 -Content {
            New-UDCard -Title "Size 6"
        }
    }
    New-UDRow -Columns {
        New-UDColumn -SmallSize 9 -SmallOffset 3 -Content {
            New-UDCard -Title "Size 12"
        }
    }
}

Start-UDDashboard -Dashboard $DashboardLayout2 -Port 10000 # -AutoReload
Start-Process http://localhost:10000
Get-UDDashboard | Stop-UDDashboard

$DashboardLayout3 = New-UDDashboard -Title Layout -Content {
    New-UDRow -Columns {
        New-UDColumn -Smallsize 12  -MediumSize 6 -LargeSize 3 -Content { # Die Standardbreite einer Seite ist 12
            New-UDCard -Title "Size 6"
        }
    }

}

Start-UDDashboard -Dashboard $DashboardLayout3 -Port 10000 # -AutoReload
Start-Process http://localhost:10000
Get-UDDashboard | Stop-UDDashboard

$PublishFolder = 'C:\temp\'
$root = $PublishFolder
# Stellt Variablen, Module und Funktionen in einem Endpoint bereit. In diesem Fall wird die 
# Variable root aber gar nicht verwendet, das Skript funktioniert also auch ohne 
$EndPointInit = New-UDEndpointInitialization -Variable Root 

$Folder = Publish-UDFolder -Path $PublishFolder -RequestPath "/files" 
# Publish-UDFolder veröffentlicht den Ordner per REST-API. Der Request-Path gibt den Ordner
# in der URL an, unter dem die Datei Datei veröffentlicht ist: 
Invoke-WebRequest -Uri http://localhost:10000/files/AppsToRemove.xml

$DashboardFiles = New-UDDashboard -Title "Downloads" -Content {
    New-UDRow -Columns {
        New-UDTable -Title "Downloads" -Headers @("Name","Size","Download") -Endpoint {
            Get-ChildItem -Path $PublishFolder -File | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name 
                    Size = "{0:0}KB" -f $_.Length
                    # Der Download-Link entspricht dem veröffentlichten Pfad (s. Publish UDFolder)
                    Download = New-UDLink -Text Download -URl "/files/$($_.Name)" 
                }
            } | Out-UDTableData -Property @("Name","Size","Download")
        }
    }
} -EndpointInitialization $EndPointInit

Start-UDDashboard -Dashboard $DashboardFiles -Port 10000 -PublishedFolder $Folder
Start-Process http://localhost:10000
Get-UDDashboard | Stop-UDDashboard

$Root = "C:\temp"
$init = New-UDEndpointInitialization -Variable ROOT

$DashboardInput = New-UDDashboard -Title "Inputs" -Content {
    New-UDInput -Title Input -EndPoint {
        param(
            [string]$InputField,
            [bool]$checkMich,
            [System.DayOfWeek]$DayInput,
            [Parameter(Helpmessage="Was soll ich tun")]
            [ValidateSet("Essen","Trinken","Schlafen")]$tuWas
        )

        # $InputField | Out-File ( Join-Path $root "output.txt" )
        
        # New-UDInputAction -Toast $tuWas
        # New-UDInputAction -RedirectUrl "https://www.netz-weise.de"
        New-UDInputAction -Content @(
            New-UDCard -Title $InputField
        )
    }
 
} -EndpointInitialization $EndPointInit

Start-UDDashboard -Dashboard $DashboardInput -Port 10000
Start-Process http://localhost:10000
Get-UDDashboard | Stop-UDDashboard
