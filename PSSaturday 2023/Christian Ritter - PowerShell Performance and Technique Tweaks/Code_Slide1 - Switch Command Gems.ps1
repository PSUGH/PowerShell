# Title: Switch Command Gems
break


# Did you know about regex flags/params?
get-help about_Switch -ShowWindow


#Region The Bad

    # Initialize health
    $health = 60

    # Initialize selected food
    $FoodSelection = @('Apple','Junk food')

    foreach ($food in $FoodSelection) {
        if ($food -eq 'Apple') {
            $health += 5
        }
        elseif ($food -eq 'broccoli') {
            $health += 10
        }
        elseif ($food -eq 'banana') {
            $health += 5
        }
        elseif ($food -eq 'junk food') {
            $health += -3
        }
        else {
            Write-Host 'Unknown food'
            $health += -10
        }
    }

    Write-Host "After eating your new health is: $health"

#EndRegion The Bad

break

#Region The Ugly

    # Initialize health
    $health = 60

    # Initialize selected food
    $FoodSelection = @('Apple','banana')

    switch($FoodSelection){
        'Apple' {
            $health +=  5
        }
        'broccoli' {
            $health +=  10
        }'banana' {
            $health +=  5
        }'junk food' {
            $health +=  -3
        }
        default{
            Write-Host 'Unknown food'
            $health += -10
        }
    }
    Write-Host "After eating your new health is:'$health'"


#EndRegion The Ugly

break

#Region The Good

    # Initialize health
    $health = 60

    # Initialize selected food
    $FoodSelection = @('apple','banana')

    switch -Regex ($FoodSelection){
        '^(apple|banana)$' {
            $health += 5
        }
        '^(broccoli)$' {
            $health += 10
        }'^(junk food)$' {
            $health +=  -3
        }
        default{
            Write-Host 'Unknown food'
            $health += -10
        }
    }
    Write-Host "After eating your new health is:'$health'"

#EndRegion The Good

break

#Region The Awsome

    $Food = @{
        banana = 5
        apple = 5
        broccoli = 10
        junkfood = -3
    }

    $FoodSelection = @('apple','poison')
    $health = 60

    foreach ($SelectedFood in $FoodSelection) {
        $health += $Food.ContainsKey($SelectedFood) ? $Food[$SelectedFood] : -10
    }
    Write-Host "After eating your new health is:'$health'"

#EndRegion The Good
