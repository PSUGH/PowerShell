# Title: Querying
break

#Region Setup

    # First things first
    Import-Module Benchpress

    # Import a large csv
    $FilePath = "C:\Users\christian.ritter\OneDrive - CANCOM GmbH\Dokumente\Repos\GitHub-Repos\PS_Saturday_Session_2023\titanic.csv"
    $Import = Import-CSV -Delimiter "," -Path $FilePath

#EndRegion Setup

break

#Region The Methods

    #Region Method 1: Linq 
        
        $delegate = [Func[object,bool]] { $args[0].Sex -eq "male" }
        $Result = [Linq.Enumerable]::Where($Import, $delegate)
        $Result = [Linq.Enumerable]::ToList($Result)

    #EndRegion Method 1: Linq 

    break

    #Region Method 2: Piped Where

        $Result = $Import | Where-Object{$_.Sex -eq "male"}

    #EndRegion Method 2: Piped Where 


    break

    #Region Method 3: .where()

        $Result = $Import.Where({$_.Sex -eq "male"})

    #EndRegion Method 3: .where()

    break

    #Region Method 4: Switch -File

    $Result = Switch -file ($FilePath){
        Default{
            if(($PSItem.split(","))[5]-eq 'male'){
                $PSItem
            }
        }
    }

    #EndRegion Method 4: Switch -File

#EndRegion The Methods

break

#Region The Tests

    bench -Technique @{
        "Linq" = {
            
            # Import a large csv
            $Import = Import-CSV -Delimiter "," -Path $FilePath

            $delegate = [Func[object,bool]] { $args[0].Sex -eq "male" }
            $Result = [Linq.Enumerable]::Where($Import, $delegate)
            $Result = [Linq.Enumerable]::ToList($Result)
        }
        "Piped Where" = {

            # Import a large csv
            $Import = Import-CSV -Delimiter "," -Path $FilePath

            $Result = $Import | Where-Object{$_.Sex -eq "male"}
        }
        ".where()" = {

            # Import a large csv
            $Import = Import-CSV -Delimiter "," -Path $FilePath

            $Result = $Import.Where({$_.Sex -eq "male"})
        }
        "Switch -File" = {
            $Import = Import-CSV -Delimiter "," -Path $FilePath

            $Result = Switch -file ($FilePath){
                Default{
                    if(($PSItem.split(","))[5]-eq 'male'){
                        $PSItem
                    }
                }
            }
        }
    } -GroupName "Read Large Files" -RepeatCount 4

#EndRegion

break
