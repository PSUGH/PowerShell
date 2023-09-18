# Title: Sort-Unique
break

#Region Setup

    #List elements
    $ListOptionA ="Blue","Red","Green"
    $ListOptionb ="Dog","Horse","Cat"

    #Create a small set of strings based on list elemtents and a random number
    $ListSmall = (1..500).ForEach({
    "$($ListOptionA[$(Get-Random -Minimum 0 -Maximum ($ListOptionA.count-1))])_$($ListOptionB[$(Get-Random -Minimum 0 -Maximum ($ListOptionB.count-1))])_$(Get-Random -Maximum 10 -Minimum 0)"
    })

    #Create a medium set of strings based on list elemtents and a random number
    $ListMedium = (1..10000).ForEach({
    "$($ListOptionA[$(Get-Random -Minimum 0 -Maximum ($ListOptionA.count-1))])_$($ListOptionB[$(Get-Random -Minimum 0 -Maximum ($ListOptionB.count-1))])_$(Get-Random -Maximum 10 -Minimum 0)"
    })

    #Create a large set of strings based on list elemtents and a random number
    $ListLarge = (1..200000).ForEach({
    "$($ListOptionA[$(Get-Random -Minimum 0 -Maximum ($ListOptionA.count-1))])_$($ListOptionB[$(Get-Random -Minimum 0 -Maximum ($ListOptionB.count-1))])_$(Get-Random -Maximum 10 -Minimum 0)"
    })
    
    #Create a large set of strings based on list elemtents and a random number
    $ListExtraLarge = (1..2000000).ForEach({
        "$($ListOptionA[$(Get-Random -Minimum 0 -Maximum ($ListOptionA.count-1))])_$($ListOptionB[$(Get-Random -Minimum 0 -Maximum ($ListOptionB.count-1))])_$(Get-Random -Maximum 10 -Minimum 0)"
    })

#EndRegion Setup

break

#Region The Methods

    #Region Method 1: Sort-Object -Unique

        @('a',"b",'b',"c") | Sort-Object -Unique
        
    #EndRegion Method 1: Sort-Object -Unique
        
    break
        
    #Region Method 2: Sort-Object | Get-Unique
        
        @('a',"b",'b',"c") | Sort-Object | Get-Unique


    #EndRegion Method 2: Sort-Object | Get-Unique

    break

    #Region Method 3: [HashSet]

        $HashSet = New-Object System.Collections.Generic.HashSet[string]
        foreach($Listelement in @('a',"b",'b',"c")){
            $HashSet.Add($Listelement) | Out-Null
        }

    #EndRegion Method 3: [HashSet]

#EndRegion The Methods

break

#Region The Tests

    $AllLists = $($ListSmall, $ListMedium, $ListLarge,$ListExtraLarge)
    $Tests = foreach($List in $AllLists){
        [PSCustomObject]@{
            Size = $List.Count
            Benchmark = $Benchmark = $(
                bench -Technique @{
                    "[hashset]" = {
                        $HashSet = New-Object System.Collections.Generic.HashSet[string]
                        foreach($Listelement in $List){
                            $HashSet.Add($Listelement) | Out-Null
                        }
                    }
                    "Sort-Object | Get-Unique" = {
                        $List | Sort-Object | Get-Unique
                    }
                    "Sort-Object -Unique" = {
                        
                        $List | Sort-Object -Unique
                    }
                } -RepeatCount 1
            )
            Winner = ($Benchmark | Where-Object{
                $_.relativespeed -eq ($Benchmark.relativespeed | Measure-Object -Minimum).Minimum
            }).Technique
        }
    }
    
#EndRegion

break

#Region Checking the tests

    $Tests | Select-Object Size, Winner

    #Going deeper
    $Tests | Where-Object{ $PSItem.Size -eq $ListExtraLarge.Count } | Select-Object -ExpandProperty Benchmark
    $Tests | Where-Object{ $PSItem.Size -eq $ListLarge.Count } | Select-Object -ExpandProperty Benchmark
    $Tests | Where-Object{ $PSItem.Size -eq $ListMedium.Count } | Select-Object -ExpandProperty Benchmark
    $Tests | Where-Object{ $PSItem.Size -eq $ListSmall.Count } | Select-Object -ExpandProperty Benchmark

#EndRegion Checking the tests
