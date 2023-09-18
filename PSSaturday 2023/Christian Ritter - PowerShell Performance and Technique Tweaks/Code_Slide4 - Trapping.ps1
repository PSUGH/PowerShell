# Title: Trapping
break



#Region The Bad

    # Attempt to create a directory (this should succeed)
    New-Item -Path "C:\Example\NewDirectory" -ItemType "Directory" -Force

    # Check if the last command was successful
    if ($?) {
        Write-Host "Directory created successfully."
    } else {
        Write-Host "Failed to create the directory."
    }

    # Attempt to create the same directory again (this should fail)
    New-Item -Path "C:\Example\NewDirectory" -ItemType "Directory"

    # Check if the last command was successful
    if ($?) {
        Write-Host "Directory created successfully."
    } else {
        Write-Host "Failed to create the directory."
    }

#EndRegion The Bad

break

#Region The Ugly

    try {
        # Attempt to create the same directory again (this should fail)
        New-Item -Path "C:\Example\NewDirectory" -ItemType "Directory" -ErrorAction Stop
        Write-Host "Directory created successfully."
    }
    catch {
        Write-Host 'The directory exists'
        Write-Host $_.Exception.Message
    }

#EndRegion The Ugly

break

#Region The Good

    try {
        # Attempt to create the same directory again (this should fail)
        New-Item -Path "C:\Example\NewDirectory" -ItemType "Directory" -ErrorAction Stop
        Write-Host "Directory created successfully."
    } 
    catch [System.IO.IOException] {
        Write-Host 'The directory exists'
        Write-Host $_.Exception.Message
    }
    catch {
        Write-Host "General failure"
        Write-Host $_.Exception.Message

    }

#EndRegion The Good

break

#Region The other

    trap {
        switch($PSItem.Exception.GetType().Name){
            "IOException"{
                Write-Host 'The directory exists'
            }
            Default{
                Write-Host 'General failure'

            }
        }
    }

    New-Item -Path "C:\Example\NewDirectory" -ItemType "Directory" -ErrorAction Stop

#EndRegion The other