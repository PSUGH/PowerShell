# Title: File-Reading
break

#Region Setup

    # First things first
    Import-Module Benchpress

    # large file - ~8Mb ~1m lines
    $FilePath = "C:\Users\christian.ritter\OneDrive - CANCOM GmbH\Dokumente\Repos\GitHub-Repos\PS_Saturday_Session_2023\10-million-password-list-top-1000000.txt"

    # Test condition files longer in length than 9 characters
    $CharacterLimit = 9

#EndRegion Setup

break

#Region The Methods

    #Region Method 1: Get-Content

        $Content = Get-Content -Path $FilePath -Encoding utf8

    #EndRegion Method 1: Get-Content

    break

    #Region Method 2: [system.io.file] --> ReadAllLines()

        $Content = [system.io.file]::ReadAllLines($FilePath)

    #EndRegion Method 2: [system.io.file] --> ReadAllLines()


    break

    #Region Method 3: [System.IO.StreamReader] --> ReadLine()

        $sread = [System.IO.StreamReader]::new($FilePath) 
        $Content = while ($line = $sread.ReadLine()) {
            $line
        } 

    #EndRegion Method 3: [System.IO.StreamReader] --> ReadLine()

    break

    #Region Method 4: Switch -File

        $Content = Switch -File ($FilePath){
            Default{
            $PSitem
            }
        }

    #EndRegion Method 4: Switch -File

#EndRegion The Methods

break

#Region The Tests

    bench -Technique @{
        "Get-Content -> Where-Object" = {
            $Lines = Get-Content -Path $FilePath | Where-Object{$PSItem.Length -gt $Characterlimit}
        }
        "Get-Content -> foreach()" = {
            $Content = Get-Content -Path $FilePath
            $Lines = foreach($Line in $Content){
                if($Line.Length -gt $Characterlimit){
                    $line
                }
            }
        }
        "[system.io.file] --> ReadAllLines()" = {
            $Content = [system.io.file]::ReadAllLines($FilePath)
            $Lines = foreach ($Line in $Content){
                if($Line.Length -gt $Characterlimit){
                    $line
                }
            }
        }
        "[System.IO.StreamReader] --> ReadLine()" = {
            $sread = [System.IO.StreamReader]::new($FilePath) 
            $Lines = while ($line = $sread.ReadLine()) {
                if($Line.Length -gt $Characterlimit){
                    $Line
                }
            }
        }
        "Switch -File" = {
            $Lines = Switch -File ($FilePath){
                Default{
                    if($PSitem.Length -gt $Characterlimit){
                        $PSitem
                    }
                }
            }
        }
    } -GroupName "Read Large Files" -RepeatCount 1

#EndRegion

break

#Region Bonus Test

    bench -Technique @{
        "Switch -File --> Default case" = {
            $Lines = Switch -File ($FilePath){
                Default{
                    if($PSitem.Length -gt $Characterlimit){
                        $PSitem
                    }
                }
            }
        }
        "Switch -File --> Condition case" = {
            $Lines = Switch -File ($FilePath){
                {$PSitem.Length -gt $Characterlimit}{
                    $PSitem
                }
            }
        }
    } -GroupName "Read Large Files - only switch" -RepeatCount 1
    
#EndRegion