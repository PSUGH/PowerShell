Describe "Add-Numbers" {
   
    Context "Add Positive Numbers" {
        It "adds positive numbers" {
            $sum = Add 3 5
            $sum | Should Be 8
        }
    }

    Context "Add Negative Numbers" {
        It "adds negative numbers" {
            $sum = Add (-3) (-5)
            $sum | Should Be (-8)
        }
    }
}

Describe "EdgeCases" {
    
    Context "Add positive and negative numbers" {
        It "adds positive and negative numbers" {
            $sum = Add 3 (-5)
            $sum | Should Be (-2)
        }
    }
}