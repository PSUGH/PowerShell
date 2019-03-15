$dashboard = New-UDDashboard -Content {
    New-UDCard -Title 'DashboardText' -id DashboardText -Content {
        New-UDParagraph -Text 'Hier kann man ein bisschen spielen'
    } 

    New-UDCollapsible -Items {
        New-UDCollapsibleItem -Title "Raum 1" -Icon arrow_circle_right -Content {
            New-UDCheckbox -Label "Installieren" -id Checkbox -OnChange {
                $Element = Get-UDElement -Id CheckBox
                Set-UDElement -Id "CheckboxState" -Content $Element.Attributes["checked"]
            }
                    
        }
    }
    New-UDCollapsible -Items {
        New-UDCollapsibleItem -Title "Raum 2" -Icon arrow_circle_right -Content {
            New-UDCheckbox -Label "Installieren" -id Checkbox2 -OnChange {
                $Element = Get-UDElement -Id CheckBox2
                Set-UDElement -Id "CheckboxState" -Content $Element.Attributes["checked"]
            }        
        }
    }

    New-UDFab -ButtonColor 'green' -Icon anchor -Size Large -onClick {
        Show-UDToast -Message "Booooom!" -Duration 10000
    } -Content {
        New-UDFabButton -ButtonColor 'green' -Icon android -onClick {
            New-UDEndpoint -Endpoint {
                "Ausgabe" | Out-File C:\temp\ausgabe.txt
            } 
        }
    }

    New-UDHtml -Markup "<h3>Daten aus dem Eventlog</h3>"
    New-UDGrid -Title "Top 5 Errors" -Headers @("LogName","Quelle","Nachricht") -Properties @("Logname","Source","Message") -Endpoint {
        Get-EventLog -LogName Application -Newest 5 -EntryType Error | Select-Object @{N="Logname";e={"Application"}},Source,Message | Out-UDGridData
    } -FontColor blue -AutoRefresh -RefreshInterval 5 -DefaultSortColumn Quelle

    New-UDLayout -Columns 3 -Content {
        New-UDCounter -Title "Files c:\temp" -AutoRefresh -RefreshInterval 1 -Endpoint {
            (@(Get-ChildItem C:\temp\ -File)).Length
        } 
        New-UDCounter -Title "Folders c:\temp" -AutoRefresh -RefreshInterval 1 -Endpoint {
            (Get-ChildItem C:\temp\ -Directory).Length
        } 
        New-UDCounter -Title "Folders c:\Windows" -AutoRefresh -RefreshInterval 1 -Endpoint {
            (Get-ChildItem C:\Windows\ -File).Length
        } 
    }
    
    New-UDInput -Title Benutzername -SubmitText "�bernehmen" -Endpoint {
        param(
            [ValidateLength(3,10)]
            [UniversalDashboard.ValidationErrorMessage("Der Name war zu lang oder zu kurz")]
            [Alias('Geben Sie Ihren Namen ein')]
            [string]$name
        )
        $name | Out-File -FilePath C:\temp\Namen.txt -Append
        New-UDInputAction -Toast "Gespeichert" -Duration 1000 -ClearInput
    } -Validate

    New-UDInput -Title Adresse -SubmitText "Speichern" -Endpoint {
        param(
            [ValidateLength(3,50)]
            [UniversalDashboard.ValidationErrorMessage("ungueltige Adresse eingegeben")]
            [string]$Adresse
        )
        $Adresse | Out-File -FilePath C:\temp\Namen.txt -Append
        New-UDInputAction -Content @(
            New-UDCard -Text ($adresse)
        )
    } -Validate
<#
     New-UDInput -Title "Simple Form" -Id "Form" -Content {
        New-UDInputField -Type 'textbox' -Name 'Email' -Placeholder 'Email Address'
        New-UDInputField -Type 'checkbox' -Name 'Newsletter' -Placeholder 'Sign up for newsletter'
        New-UDInputField -Type 'select' -Name 'FavoriteLanguage' -Placeholder 'Favorite Programming Language' -Values @("PowerShell", "Python", "C#")
        New-UDInputField -Type 'radioButtons' -Name 'FavoriteEditor' -Placeholder @("Visual Studio", "Visual Studio Code", "Notepad") -Values @("VS", "VSC", "NP")
        New-UDInputField -Type 'password' -Name 'password' -Placeholder 'Password'
        New-UDInputField -Type 'textarea' -Name 'notes' -Placeholder 'Additional Notes'
    } -Endpoint {
        param($Email, $Newsletter, $FavoriteLanguage, $FavoriteEditor, $password, $notes)
    } 
#>
    New-UDInput -Title Formular -id Form -Content {
        New-UDInputField -Type "textbox" -name "Email" -Placeholder "EmailAdresse"
        New-UDInputField -Type "checkbox" -Name "Newsletter" -Placeholder "Newsletter bestellen"
        New-UDInputField -Type select -Name "Programmiersprache" -Placeholder "Programmiersprache" -Values @("Powershell","C#","Python")
        New-UDInputField -Type radioButtons -Name "Editor" -Placeholder @("VSCode","Ise","IseSteroids") -Value  @("VSC","ISE","ISES")
        New-UDInputField -Type 'password' -Name 'password' -Placeholder 'Password'
        New-UDInputField -Type 'textarea' -Name 'notes' -Placeholder 'Bemerkungen'
    } -Endpoint {
      param($Email, $Newsletter, $Programmiersprache, $Editor, $password, $notes)
      $email,$newsletter,$progammiersprache,$Editor,$password,$notes | Out-File c:\temp\Userdata.txt -Append
    }
}

Start-UDDashboard -AutoReload -Port 10000 -Dashboard $dashboard -Name Demo
# Start-Process http://localhost:10000
# Stop-UDDashboard -Name Demo
