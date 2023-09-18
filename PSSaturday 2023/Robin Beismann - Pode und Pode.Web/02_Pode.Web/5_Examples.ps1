Import-Module -Name "Pode.Web"

Start-PodeServer -Threads 4 {
    # attach to port 8080 for http
    Add-PodeEndpoint -Address 127.0.0.1 -Port 8080 -Protocol Http

    # Tell Pode to use Pode.Web
    Use-PodeWebTemplates -Title 'Example' -Theme Dark

    # Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # Import Modules
    Import-PodeModule -Name 'PSSQLite'

    #region Homepage
    Set-PodeWebHomePage -Layouts @(
        Import-PodeWebStylesheet -Url 'my-styles.css'

        New-PodeWebHero -Title 'Willkommen!' -Message 'Willkommen beim PowerShell Saturday!' -Content @()
        
        New-PodeWebGrid -Cells @(
            # Top Processes
            New-PodeWebCell -Content @(
                New-PodeWebChart -Name 'Top Prozesse' -Type Bar -AsCard -AutoRefresh -RefreshInterval 3 -ScriptBlock {
                    Get-Process |
                        Sort-Object -Property CPU -Descending |
                        Select-Object -First 10 |
                        ConvertTo-PodeWebChartData -LabelProperty ProcessName -DatasetProperty CPU, Handles
                }
            )

            # CPU Graph
            New-PodeWebCell -Content @(
                New-PodeWebCounterChart -Counter '\Processor(_Total)\% Processor Time' -AsCard -Name 'CPU Nutzung (nativer Graph)'
            )

            # CPU Time Graph
            New-PodeWebCell -Content @(
                New-PodeWebChart -Name 'CPU Nutzung (eigener Graph)' -Type Line -AutoRefresh -RefreshInterval 3 -Append -TimeLabels -MaxItems 15 -AsCard -ScriptBlock {
                    return @{
                        Values = ((Get-Counter -Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 2).CounterSamples.CookedValue | Measure-Object -Average).Average
                    }
                }
            )
        )
    )
    
    #endregion

    #region Steps
    Add-PodeWebPage -Name 'Steps' -Icon 'step-forward' -ScriptBlock {
        New-PodeWebSteps -Name 'AddUser' -Steps @(
            New-PodeWebStep -Name 'Details' -Icon 'User-Plus' -Content @(
                New-PodeWebTextbox -Name 'FirstName'
                New-PodeWebTextbox -Name 'LastName'
            )
            New-PodeWebStep -Name 'Email' -Icon 'Mail' -Content @(
                New-PodeWebTextbox -Name 'Email'
            ) -ScriptBlock {
                if ($WebEvent.Data['Email'] -inotlike '*@*') {
                    Out-PodeWebValidation -Name 'Email' -Message 'The email supplied is invalid'
                }
            }
            New-PodeWebStep -Name 'Password' -Icon 'Lock' -Content @(
                New-PodeWebTextbox -Name 'Password' -Type Password
            ) -ScriptBlock {
                if ($WebEvent.Data['Password'].Length -lt 8) {
                    Out-PodeWebValidation -Name 'Password' -Message 'Password should be 8+ characters'
                }
            }
        ) -ScriptBlock {
            Show-PodeWebToast -Message "User created: $($WebEvent.Data['FirstName']) $($WebEvent.Data['LastName'])"
        }
    }
    #endregion
   
    #region Carousel
    Add-PodeWebPage -Name 'Carousel' -Icon 'view-carousel' -ScriptBlock {
        New-PodeWebContainer -Content @(
            New-PodeWebText -Value 'Unsere Sponsoren'
        )

        New-PodeWebCarousel -Slides @(
            New-PodeWebSlide -Content @(
                New-PodeWebContainer -Nobackground -Content @(
                    New-PodeWebImage -Source 'https://pssat.de/images/netzweise/netzweise.svg' -Alignment Center -Height 300
                )
            )
            New-PodeWebSlide -Content @(
                New-PodeWebContainer -Nobackground -Content @(
                    New-PodeWebImage -Source 'https://pssat.de/images/scriptrunner/scriptrunner-logo_rgb_original-claim.svg' -Alignment Center -Height 300
                )
            )
            New-PodeWebSlide -Content @(
                New-PodeWebContainer -Nobackground -Content @(
                    New-PodeWebImage -Source 'https://pssat.de/images/au2mator/au2mator.png' -Alignment Center -Height 300
                )
            )
            New-PodeWebSlide -Content @(
                New-PodeWebContainer -Nobackground -Content @(
                    New-PodeWebImage -Source 'https://pssat.de/images/grammlins/grammlins.png' -Alignment Center -Height 150
                )
            )
        )
    }
    #endregion
   
    #region Accordion
    Add-PodeWebPage -Name 'Accordion' -Icon 'collapse-all' -ScriptBlock {
        New-PodeWebContainer -Content @(
            New-PodeWebText -Value 'Unsere Sponsoren'
        )

        New-PodeWebAccordion -Cycle -CycleInterval 5 -Bellows @(
            New-PodeWebBellow -Name 'Netz-Weise' -Content @(
                New-PodeWebImage -Source 'https://pssat.de/images/netzweise/netzweise.svg' -Alignment Center -Height 300
            )
            New-PodeWebBellow -Name 'Scriptrunner' -Content @(
                New-PodeWebImage -Source 'https://pssat.de/images/scriptrunner/scriptrunner-logo_rgb_original-claim.svg' -Alignment Center -Height 300
            )
            New-PodeWebBellow -Name 'Au2mator' -Content @(
                New-PodeWebImage -Source 'https://pssat.de/images/au2mator/au2mator.png' -Alignment Center -Height 300
            )
            New-PodeWebBellow -Name 'Gramm, Lins & Partner' -Content @(
                New-PodeWebImage -Source 'https://pssat.de/images/grammlins/grammlins.png' -Alignment Center -Height 150
            )
        )
    }
    #endregion   

    #region Tabs
    Add-PodeWebPage -Name 'Tabs' -Icon 'tab' -ScriptBlock {
        New-PodeWebContainer -Content @(
            New-PodeWebText -Value 'Unsere Sponsoren'
        )

        New-PodeWebTabs -Cycle -CycleInterval 5 -Tabs @(
            New-PodeWebTab -Name 'Netz-Weise' -Layouts @(
                New-PodeWebImage -Source 'https://pssat.de/images/netzweise/netzweise.svg' -Alignment Center -Height 300
            )
            New-PodeWebTab -Name 'Scriptrunner' -Layouts @(
                New-PodeWebImage -Source 'https://pssat.de/images/scriptrunner/scriptrunner-logo_rgb_original-claim.svg' -Alignment Center -Height 300
            )
            New-PodeWebTab -Name 'Au2mator' -Layouts @(
                New-PodeWebImage -Source 'https://pssat.de/images/au2mator/au2mator.png' -Alignment Center -Height 300
            )
            New-PodeWebTab -Name 'Gramm, Lins & Partner' -Layouts @(
                New-PodeWebImage -Source 'https://pssat.de/images/grammlins/grammlins.png' -Alignment Center -Height 150
            )
        )
    }
    #endregion   

    #region Datenbank Zugriff 1
    Add-PodeWebPage -Name 'Table - Datenbank Zugriff 1' -Icon 'step-forward' -ScriptBlock {

        New-PodeWebTable -Name 'Example' -AsCard -ScriptBlock {
            Invoke-SqliteQuery -DataSource "$PSScriptRoot\db.sqlite" -Query 'SELECT * FROM speaker' -As PSObject
        }
    }
    #endregion

    #region Datenbank Zugriff 2
    Add-PodeWebPage -Name 'Table - Datenbank Zugriff 2' -Icon 'step-forward' -ScriptBlock {
        New-PodeWebTable -Name 'Speaker' -Paginate -PageSize 10 -AsCard -ScriptBlock {            
            $data = Invoke-SqliteQuery -DataSource "$PSScriptRoot\db.sqlite" -Query 'SELECT * FROM speaker' -As PSObject
        
            # apply paging
            $totalCount = $data.Length
            $pageIndex = [int]$WebEvent.Data.PageIndex
            $pageSize = [int]$WebEvent.Data.PageSize

            $data = $data[(($pageIndex - 1) * $pageSize) .. (($pageIndex * $pageSize) - 1)]
        
            # update table
            $data | Update-PodeWebTable -Name 'Speaker' -PageIndex $pageIndex -TotalItemCount $totalCount
        }
    }
    #endregion

    #region Datenbank Zugriff 3
    Add-PodeWebPage -Name 'Table - Datenbank Zugriff 3' -Icon 'step-forward' -ScriptBlock {
        New-PodeWebTable -Name 'Speaker' -Paginate -PageSize 10 -AsCard -ScriptBlock {            
            $data = Invoke-SqliteQuery -DataSource "$PSScriptRoot\db.sqlite" -Query 'SELECT * FROM speaker' -As PSObject
        
            # apply paging
            $totalCount = $data.Length
            $pageIndex = [int]$WebEvent.Data.PageIndex
            $pageSize = [int]$WebEvent.Data.PageSize

            $data = $data[(($pageIndex - 1) * $pageSize) .. (($pageIndex * $pageSize) - 1)]
        
            # update table
            $data | Update-PodeWebTable -Name 'Speaker' -PageIndex $pageIndex -TotalItemCount $totalCount
        }
        New-PodeWebCard -Content @(
            New-PodeWebForm -Name 'Add Speaker' -ScriptBlock {
                $query = "
                    INSERT INTO speaker ('FirstName', 'LastName') VALUES (@FirstName,@LastName);
                "
                Invoke-SqliteQuery -DataSource "$PSScriptRoot\db.sqlite" -Query $query -SqlParameters @{
                    FirstName = $WebEvent.Data.FirstName
                    LastName = $WebEvent.Data.LastName
                }
                Sync-PodeWebTable -Name 'Speaker'
            } -Content @(
                New-PodeWebTextbox -Name 'FirstName'
                New-PodeWebTextbox -Name 'LastName'
            )
        )
    }
    #endregion

    #region Datenbank Zugriff 4
    Add-PodeWebPage -Name 'Table - Datenbank Zugriff 4' -Icon 'step-forward' -ScriptBlock {
        New-PodeWebTable -Name 'Speaker' -Paginate -PageSize 10 -AsCard -ScriptBlock {            
            $data = Invoke-SqliteQuery -DataSource "$PSScriptRoot\db.sqlite" -Query 'SELECT * FROM speaker' -As PSObject
        
            # apply paging
            $totalCount = $data.Length
            $pageIndex = [int]$WebEvent.Data.PageIndex
            $pageSize = [int]$WebEvent.Data.PageSize

            $data = $data[(($pageIndex - 1) * $pageSize) .. (($pageIndex * $pageSize) - 1)]
        
            $data | Foreach-Object {
                $_ | Add-Member -MemberType 'NoteProperty' -Name 'Actions' -Value (
                    New-PodeWebButton -Name 'Delete' -DataValue $_.id -ScriptBlock {                        
                        $query = "
                            DELETE FROM speaker WHERE id = @Id
                        "
                        Invoke-SqliteQuery -DataSource "$PSScriptRoot\db.sqlite" -Query $query -SqlParameters @{
                            Id = $WebEvent.Data['Value']
                        }
                        Show-PodeWebToast -Message "Speaker deleted!"
                        Sync-PodeWebTable -Name 'Speaker'
                    }
                )
            }

            # update table
            $data | Update-PodeWebTable -Name 'Speaker' -PageIndex $pageIndex -TotalItemCount $totalCount
        }
        New-PodeWebCard -Content @(
            New-PodeWebForm -Name 'Add Speaker' -ScriptBlock {
                $query = "
                    INSERT INTO speaker ('FirstName', 'LastName') VALUES (@FirstName,@LastName);
                "
                Invoke-SqliteQuery -DataSource "$PSScriptRoot\db.sqlite" -Query $query -SqlParameters @{
                    FirstName = $WebEvent.Data.FirstName
                    LastName = $WebEvent.Data.LastName
                }
                Show-PodeWebToast -Message "Created new Speaker: $($WebEvent.Data.FirstName) $($WebEvent.Data.LastName)"
                Sync-PodeWebTable -Name 'Speaker'
            } -Content @(
                New-PodeWebTextbox -Name 'FirstName'
                New-PodeWebTextbox -Name 'LastName'
            )
        )
    }
    #endregion

    #region Navigation Dropdown
    $navDropdown = New-PodeWebNavDropdown -Name 'Websites' -Icon 'link-variant' -Items @(
        New-PodeWebNavLink -Name 'PSSat' -Url 'https://pssat.de' -Icon 'account-cowboy-hat'
        New-PodeWebNavLink -Name 'PSUGH' -Url 'https://psugh.de' -Icon 'account-group'
        New-PodeWebNavDivider
        New-PodeWebNavLink -Name 'Meetup' -Url 'https://www.meetup.com/psugh-hannover/events/291224383/' -Icon 'alpha-m-box'
    )
    Set-PodeWebNavDefault -Items $navDropdown
    #endregion

}